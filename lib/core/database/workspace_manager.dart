import 'dart:async';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../crypto/pin_crypto.dart';
import 'connection/database_connection.dart';
import 'device_database.dart';
import 'workspace_database.dart';

/// Dynamic Multi-Database Workspace Manager for Pindea
/// Manages 1 physical SQLite database per workspace and the central device database.
class WorkspaceManager {
  static const _uuid = Uuid();

  final DeviceDatabase deviceDb;
  final Map<String, WorkspaceDatabase> _activeWorkspacePool = {};
  String? _activeWorkspaceId;

  WorkspaceManager({required this.deviceDb});

  /// Initialize the workspace manager with a default user and default personal workspace if empty
  Future<void> initializeDefaultIfEmpty() async {
    final existingUsers = await deviceDb.select(deviceDb.localUsers).get();
    if (existingUsers.isEmpty) {
      final defaultUserId = _uuid.v4();
      await deviceDb.into(deviceDb.localUsers).insert(
            LocalUsersCompanion.insert(
              userId: defaultUserId,
              displayName: 'Pengguna',
              createdAt: DateTime.now(),
            ),
          );

      // Create default personal workspace (unencrypted by default)
      final defaultWorkspaceId = _uuid.v4();
      await deviceDb.into(deviceDb.workspaces).insert(
            WorkspacesCompanion.insert(
              workspaceId: defaultWorkspaceId,
              type: 'private',
              ownerId: defaultUserId,
              name: 'Personal',
            ),
          );

      _activeWorkspaceId = defaultWorkspaceId;
    } else {
      final workspaces = await deviceDb.select(deviceDb.workspaces).get();
      if (workspaces.isNotEmpty) {
        _activeWorkspaceId = workspaces.first.workspaceId;
      }
    }
  }

  /// Get the current active workspace ID
  String? get activeWorkspaceId => _activeWorkspaceId;

  /// Set the active workspace
  void setActiveWorkspace(String workspaceId) {
    _activeWorkspaceId = workspaceId;
  }

  /// Open or retrieve an existing database connection for a workspace
  Future<WorkspaceDatabase> getWorkspaceDatabase(
    String workspaceId, {
    String? pin,
  }) async {
    if (_activeWorkspacePool.containsKey(workspaceId)) {
      return _activeWorkspacePool[workspaceId]!;
    }

    // Check workspace record in deviceDb
    final workspaceList = await (deviceDb.select(deviceDb.workspaces)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId)))
        .get();

    if (workspaceList.isEmpty) {
      throw ArgumentError('Workspace not found: $workspaceId');
    }

    final workspace = workspaceList.first;
    String? derivedKey;

    if (workspace.isEncrypted) {
      if (pin == null || pin.isEmpty) {
        throw StateError('PIN is required to open encrypted workspace: $workspaceId');
      }

      // Look up user PIN verifier
      final userList = await (deviceDb.select(deviceDb.localUsers)
            ..where((tbl) => tbl.userId.equals(workspace.ownerId)))
          .get();

      if (userList.isEmpty || userList.first.pinVerifier == null) {
        throw StateError('Owner PIN verifier not found for encrypted workspace');
      }

      final user = userList.first;
      final isValid = PinCrypto.verifyPin(
        pin: pin,
        salt: user.pinSalt ?? '',
        verifier: user.pinVerifier!,
      );

      if (!isValid) {
        throw ArgumentError('PIN salah untuk workspace ini');
      }

      derivedKey = PinCrypto.deriveKey(pin: pin, salt: user.pinSalt ?? '');
    }

    final connection = DatabaseConnectionFactory.createConnection(
      'workspace_$workspaceId.db',
      encryptionKey: derivedKey,
    );

    final db = WorkspaceDatabase(connection);
    _activeWorkspacePool[workspaceId] = db;
    return db;
  }

  /// Create a new workspace (optionally encrypted with PIN)
  Future<String> createWorkspace({
    required String name,
    required String type, // 'private' or 'shared'
    required String ownerId,
    bool isEncrypted = false,
    String? pin,
  }) async {
    final workspaceId = _uuid.v4();

    if (isEncrypted) {
      if (pin == null || pin.length < 4) {
        throw ArgumentError('PIN minimal 4 digit diperlukan untuk enkripsi');
      }
    }

    await deviceDb.into(deviceDb.workspaces).insert(
          WorkspacesCompanion.insert(
            workspaceId: workspaceId,
            type: type,
            ownerId: ownerId,
            name: name,
            isEncrypted: Value(isEncrypted),
          ),
        );

    // Warm up the database file
    await getWorkspaceDatabase(workspaceId, pin: pin);

    return workspaceId;
  }

  /// Close and remove a workspace connection from pool
  Future<void> closeWorkspace(String workspaceId) async {
    final db = _activeWorkspacePool.remove(workspaceId);
    if (db != null) {
      await db.close();
    }
  }

  /// Close all open database connections
  Future<void> dispose() async {
    for (final db in _activeWorkspacePool.values) {
      await db.close();
    }
    _activeWorkspacePool.clear();
    await deviceDb.close();
  }
}
