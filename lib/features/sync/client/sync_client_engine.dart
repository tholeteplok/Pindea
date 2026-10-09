import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import '../../../core/database/device_database.dart';
import '../../../core/database/workspace_database.dart';
import '../../../core/database/workspace_manager.dart';
import '../pairing/pairing_payload.dart';

/// Sync Client Engine (Used by Android & Desktop Peer Clients)
/// Implements Pull-then-Push replication cycle over LAN.
class SyncClientEngine {
  final DeviceDatabase deviceDb;
  final WorkspaceManager workspaceManager;
  final http.Client httpClient;

  SyncClientEngine({
    required this.deviceDb,
    required this.workspaceManager,
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  /// Pair client with a Hub using scanned PairingPayload QR code
  Future<bool> pairWithHub(
    PairingPayload payload, {
    required String deviceId,
    required String deviceName,
    String platform = 'android',
  }) async {
    if (payload.isExpired) {
      throw StateError('QR Code pairing telah kedaluwarsa (lebih dari 120 detik)');
    }

    // Try available IP addresses
    for (final ip in payload.addresses) {
      try {
        final url = Uri.parse('http://$ip:${payload.port}/v1/pair');
        final response = await httpClient.post(
          url,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'token': payload.token,
            'device_id': deviceId,
            'device_name': deviceName,
            'platform': platform,
            'user_id': payload.userId,
          }),
        );

        if (response.statusCode == 200) {
          // Record Hub in paired devices
          await deviceDb.into(deviceDb.pairedDevices).insertOnConflictUpdate(
                PairedDevicesCompanion(
                  deviceId: Value(payload.hubId),
                  name: Value(payload.name),
                  platform: const Value('desktop_hub'),
                  userId: Value(payload.userId),
                  pairedAt: Value(DateTime.now()),
                  lastSyncAt: Value(DateTime.now()),
                ),
              );
          return true;
        }
      } catch (_) {
        // Try next IP address
      }
    }
    return false;
  }

  /// Perform full replication cycle for a workspace (Pull first, then Push)
  Future<Map<String, int>> syncWorkspace(
    String hubHost,
    int hubPort,
    String workspaceId, {
    required String deviceId,
  }) async {
    final wsDb = await workspaceManager.getWorkspaceDatabase(workspaceId);

    // Get current cursor
    final cursorRow = await (wsDb.select(wsDb.syncCursors)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId)))
        .get();

    final lastPulledSeq = cursorRow.isNotEmpty ? cursorRow.first.lastPulledSeq : 0;
    final lastPushedSeq = cursorRow.isNotEmpty ? cursorRow.first.lastPushedSeq : 0;

    int pulledCount = 0;
    int pushedCount = 0;

    // --- 1. PULL PHASE ---
    final pullUrl = Uri.parse('http://$hubHost:$hubPort/v1/sync/pull');
    final pullRes = await httpClient.post(
      pullUrl,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'workspace_id': workspaceId,
        'cursor': lastPulledSeq,
        'limit': 100,
      }),
    );

    if (pullRes.statusCode == 200) {
      final pullData = jsonDecode(pullRes.body) as Map<String, dynamic>;
      final remoteChanges = pullData['changes'] as List<dynamic>? ?? [];
      final newPulledCursor = pullData['cursor'] as int? ?? lastPulledSeq;

      for (final item in remoteChanges) {
        final c = item as Map<String, dynamic>;
        final changeId = c['change_id'] as String;
        final hlc = c['hlc'] as String;
        final entityType = c['entity_type'] as String;
        final entityId = c['entity_id'] as String;
        final op = c['op'] as String;
        final payload = c['payload'] as String;
        final remoteDeviceId = c['device_id'] as String;

        // Apply idempotently
        final existing = await (wsDb.select(wsDb.syncChanges)
              ..where((tbl) => tbl.changeId.equals(changeId)))
            .get();

        if (existing.isEmpty) {
          await _applyRemoteChange(wsDb, entityType, entityId, op, payload, hlc);

          await wsDb.into(wsDb.syncChanges).insert(
                SyncChangesCompanion.insert(
                  changeId: changeId,
                  workspaceId: workspaceId,
                  deviceId: remoteDeviceId,
                  hlc: hlc,
                  entityType: entityType,
                  entityId: entityId,
                  op: op,
                  payload: payload,
                ),
              );
          pulledCount++;
        }
      }

      // Update pulled cursor
      await wsDb.into(wsDb.syncCursors).insertOnConflictUpdate(
            SyncCursorsCompanion(
              peerDeviceId: Value(hubHost),
              workspaceId: Value(workspaceId),
              lastPulledSeq: Value(newPulledCursor),
            ),
          );
    }

    // --- 2. PUSH PHASE ---
    final localChanges = await (wsDb.select(wsDb.syncChanges)
          ..where((tbl) => tbl.seq.isBiggerThanValue(lastPushedSeq) & tbl.deviceId.equals(deviceId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.seq)]))
        .get();

    if (localChanges.isNotEmpty) {
      final pushUrl = Uri.parse('http://$hubHost:$hubPort/v1/sync/push');
      final pushRes = await httpClient.post(
        pushUrl,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'workspace_id': workspaceId,
          'changes': localChanges
              .map((c) => {
                    'change_id': c.changeId,
                    'device_id': c.deviceId,
                    'hlc': c.hlc,
                    'entity_type': c.entityType,
                    'entity_id': c.entityId,
                    'op': c.op,
                    'payload': c.payload,
                    'seq': c.seq,
                  })
              .toList(),
        }),
      );

      if (pushRes.statusCode == 200) {
        pushedCount = localChanges.length;
        final newPushedCursor = localChanges.last.seq;

        await wsDb.into(wsDb.syncCursors).insertOnConflictUpdate(
              SyncCursorsCompanion(
                peerDeviceId: Value(hubHost),
                workspaceId: Value(workspaceId),
                lastPushedSeq: Value(newPushedCursor),
              ),
            );
      }
    }

    return {
      'pulled': pulledCount,
      'pushed': pushedCount,
    };
  }

  Future<void> _applyRemoteChange(
    WorkspaceDatabase wsDb,
    String entityType,
    String entityId,
    String op,
    String payloadRaw,
    String hlc,
  ) async {
    final payload = jsonDecode(payloadRaw) as Map<String, dynamic>;

    if (entityType == 'note') {
      if (op == 'delete') {
        await (wsDb.update(wsDb.notes)..where((tbl) => tbl.noteId.equals(entityId))).write(
          NotesCompanion(
            deletedAt: Value(DateTime.now()),
            updatedHlc: Value(hlc),
          ),
        );
      } else {
        await wsDb.into(wsDb.notes).insertOnConflictUpdate(
              NotesCompanion(
                noteId: Value(entityId),
                workspaceId: Value(payload['workspace_id'] as String? ?? 'default'),
                title: Value(payload['title'] as String? ?? ''),
                createdAt: Value(DateTime.tryParse(payload['created_at'] as String? ?? '') ?? DateTime.now()),
                updatedHlc: Value(hlc),
              ),
            );
      }
    } else if (entityType == 'block') {
      if (op == 'delete') {
        await (wsDb.update(wsDb.blocks)..where((tbl) => tbl.blockId.equals(entityId))).write(
          BlocksCompanion(
            deletedAt: Value(DateTime.now()),
            updatedHlc: Value(hlc),
          ),
        );
      } else {
        await wsDb.into(wsDb.blocks).insertOnConflictUpdate(
              BlocksCompanion(
                blockId: Value(entityId),
                noteId: Value(payload['note_id'] as String? ?? ''),
                type: Value(payload['type'] as String? ?? 'text'),
                position: Value(payload['position'] as String? ?? 'a0'),
                content: Value(payload['content'] as String? ?? ''),
                updatedHlc: Value(hlc),
              ),
            );
      }
    }
  }
}
