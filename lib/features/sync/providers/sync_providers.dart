import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers/database_providers.dart';
import '../client/sync_client_engine.dart';
import '../hub/sync_hub_server.dart';

/// Provider for local LAN Sync Hub Server (Desktop Hub / Local Server)
final syncHubServerProvider = Provider<SyncHubServer>((ref) {
  final deviceDb = ref.watch(deviceDatabaseProvider);
  final workspaceManager = ref.watch(workspaceManagerProvider);

  final server = SyncHubServer(
    hubId: 'desktop-hub-01',
    hubName: 'PC-Pindea',
    workspaceManager: workspaceManager,
    deviceDb: deviceDb,
  );

  ref.onDispose(() => server.stop());
  return server;
});

/// Provider for Sync Client Engine (Android / Peer Client)
final syncClientEngineProvider = Provider<SyncClientEngine>((ref) {
  final deviceDb = ref.watch(deviceDatabaseProvider);
  final workspaceManager = ref.watch(workspaceManagerProvider);

  return SyncClientEngine(
    deviceDb: deviceDb,
    workspaceManager: workspaceManager,
  );
});
