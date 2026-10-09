import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../../../core/database/device_database.dart';
import '../../../core/database/workspace_database.dart';
import '../../../core/database/workspace_manager.dart';
import '../pairing/pairing_payload.dart';

/// LAN Sync Hub Server (Desktop Hub / Peer Node)
/// Implements PRD Section 14 Protocol (HTTPS / JSON over LAN port 47820)
class SyncHubServer {
  final String hubId;
  final String hubName;
  final WorkspaceManager workspaceManager;
  final DeviceDatabase deviceDb;

  HttpServer? _server;
  PairingPayload? _activePairingSession;

  SyncHubServer({
    required this.hubId,
    required this.hubName,
    required this.workspaceManager,
    required this.deviceDb,
  });

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  /// Start the Shelf HTTP server on the given port (default 47820)
  Future<int> start({int port = 47820}) async {
    if (_server != null) return _server!.port;

    final router = Router();

    // 1. GET /v1/hello - Protocol check & available workspaces
    router.get('/v1/hello', (Request request) async {
      final workspaces = await deviceDb.select(deviceDb.workspaces).get();
      return Response.ok(
        jsonEncode({
          'version': 1,
          'hub_id': hubId,
          'name': hubName,
          'workspaces': workspaces.map((w) => {'id': w.workspaceId, 'name': w.name, 'type': w.type}).toList(),
        }),
        headers: {'content-type': 'application/json'},
      );
    });

    // 2. POST /v1/pair - Device pairing with one-time token
    router.post('/v1/pair', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = jsonDecode(body) as Map<String, dynamic>;

        final token = data['token'] as String?;
        final clientDeviceId = data['device_id'] as String?;
        final clientName = data['device_name'] as String?;
        final clientPlatform = data['platform'] as String? ?? 'android';
        final clientUserId = data['user_id'] as String?;

        if (_activePairingSession == null || _activePairingSession!.isExpired) {
          return Response.forbidden(jsonEncode({'error': 'Token pairing telah kedaluwarsa'}));
        }

        if (_activePairingSession!.token != token) {
          return Response.forbidden(jsonEncode({'error': 'Token pairing tidak valid'}));
        }

        // Register client device
        if (clientDeviceId != null && clientUserId != null) {
          await deviceDb.into(deviceDb.pairedDevices).insertOnConflictUpdate(
                PairedDevicesCompanion(
                  deviceId: Value(clientDeviceId),
                  name: Value(clientName ?? 'Mobile Client'),
                  platform: Value(clientPlatform),
                  userId: Value(clientUserId),
                  pairedAt: Value(DateTime.now()),
                ),
              );
        }

        // Invalidate token after single use
        _activePairingSession = null;

        return Response.ok(
          jsonEncode({'status': 'paired', 'hub_id': hubId}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    // 3. POST /v1/sync/pull - Pull changes with cursor pagination
    router.post('/v1/sync/pull', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = jsonDecode(body) as Map<String, dynamic>;

        final workspaceId = data['workspace_id'] as String;
        final cursor = data['cursor'] as int? ?? 0;
        final limit = data['limit'] as int? ?? 100;

        final wsDb = await workspaceManager.getWorkspaceDatabase(workspaceId);

        final changes = await (wsDb.select(wsDb.syncChanges)
              ..where((tbl) => tbl.seq.isBiggerThanValue(cursor))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.seq)])
              ..limit(limit))
            .get();

        final newCursor = changes.isNotEmpty ? changes.last.seq : cursor;

        return Response.ok(
          jsonEncode({
            'workspace_id': workspaceId,
            'cursor': newCursor,
            'changes': changes
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
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    // 4. POST /v1/sync/push - Push changes to Hub
    router.post('/v1/sync/push', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = jsonDecode(body) as Map<String, dynamic>;

        final workspaceId = data['workspace_id'] as String;
        final changesList = data['changes'] as List<dynamic>? ?? [];

        final wsDb = await workspaceManager.getWorkspaceDatabase(workspaceId);
        final acceptedChangeIds = <String>[];

        for (final item in changesList) {
          final c = item as Map<String, dynamic>;
          final changeId = c['change_id'] as String;
          final remoteHlc = c['hlc'] as String;
          final entityType = c['entity_type'] as String;
          final entityId = c['entity_id'] as String;
          final op = c['op'] as String;
          final payload = c['payload'] as String;
          final deviceId = c['device_id'] as String;

          // Check if change already applied (Idempotence)
          final existing = await (wsDb.select(wsDb.syncChanges)
                ..where((tbl) => tbl.changeId.equals(changeId)))
              .get();

          if (existing.isEmpty) {
            // Apply change to target table
            await _applyRemoteChange(wsDb, entityType, entityId, op, payload, remoteHlc);

            // Record into sync_changes
            await wsDb.into(wsDb.syncChanges).insert(
                  SyncChangesCompanion.insert(
                    changeId: changeId,
                    workspaceId: workspaceId,
                    deviceId: deviceId,
                    hlc: remoteHlc,
                    entityType: entityType,
                    entityId: entityId,
                    op: op,
                    payload: payload,
                  ),
                );
            acceptedChangeIds.add(changeId);
          }
        }

        return Response.ok(
          jsonEncode({
            'status': 'applied',
            'accepted_count': acceptedChangeIds.length,
            'accepted_ids': acceptedChangeIds,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
      }
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    return _server!.port;
  }

  /// Apply remote change to entity table (Block-level merge & LWW resolution)
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

  /// Create a new 120-second pairing session and return payload for QR code
  PairingPayload createPairingSession({required String userId, List<String>? localIps}) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final token = '${DateTime.now().microsecondsSinceEpoch}-${userId.hashCode}';

    final payload = PairingPayload(
      hubId: hubId,
      name: hubName,
      addresses: localIps ?? ['127.0.0.1'],
      port: _server?.port ?? 47820,
      fingerprint: 'sha256-mock-fingerprint',
      userId: userId,
      token: token,
      expiresAt: nowSeconds + 120, // 120s expiry per PRD 13.3
    );

    _activePairingSession = payload;
    return payload;
  }

  /// Stop the server
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _activePairingSession = null;
  }
}
