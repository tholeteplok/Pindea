import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connection/database_connection.dart';
import '../device_database.dart';
import '../workspace_database.dart';
import '../workspace_manager.dart';

/// Central Device Database Provider (Holds user profiles, workspaces registry, settings)
final deviceDatabaseProvider = Provider<DeviceDatabase>((ref) {
  final connection = DatabaseConnectionFactory.createConnection('app_device.db');
  final db = DeviceDatabase(connection);
  ref.onDispose(() => db.close());
  return db;
});

/// Workspace Manager Provider (Controls multi-database connections and PIN unlocking)
final workspaceManagerProvider = Provider<WorkspaceManager>((ref) {
  final deviceDb = ref.watch(deviceDatabaseProvider);
  final manager = WorkspaceManager(deviceDb: deviceDb);
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// State Provider for Current Active Workspace ID
final activeWorkspaceIdProvider = StateProvider<String?>((ref) => null);

/// FutureProvider to initialize and get the active WorkspaceDatabase
final currentWorkspaceDatabaseProvider = FutureProvider<WorkspaceDatabase?>((ref) async {
  final manager = ref.watch(workspaceManagerProvider);
  final activeId = ref.watch(activeWorkspaceIdProvider);

  if (activeId == null) {
    await manager.initializeDefaultIfEmpty();
    final newActiveId = manager.activeWorkspaceId;
    if (newActiveId != null) {
      ref.read(activeWorkspaceIdProvider.notifier).state = newActiveId;
      return manager.getWorkspaceDatabase(newActiveId);
    }
    return null;
  }

  return manager.getWorkspaceDatabase(activeId);
});

/// Stream of all registered workspaces on this device
final allWorkspacesStreamProvider = StreamProvider<List<Workspace>>((ref) {
  final deviceDb = ref.watch(deviceDatabaseProvider);
  return deviceDb.select(deviceDb.workspaces).watch();
});
