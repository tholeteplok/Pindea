import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindea/core/database/device_database.dart';
import 'package:pindea/core/database/workspace_database.dart';
import 'package:pindea/core/database/workspace_manager.dart';
import 'package:pindea/features/sync/client/sync_client_engine.dart';
import 'package:pindea/features/sync/hub/sync_hub_server.dart';
import 'package:pindea/features/sync/pairing/pairing_payload.dart';

// Test workspace manager using in-memory databases
class MemoryWorkspaceManager extends WorkspaceManager {
  final WorkspaceDatabase testWsDb;

  MemoryWorkspaceManager({
    required super.deviceDb,
    required this.testWsDb,
  });

  @override
  Future<WorkspaceDatabase> getWorkspaceDatabase(String workspaceId, {String? pin}) async {
    return testWsDb;
  }
}

void main() {
  group('PairingPayload Tests', () {
    test('Serializes to JSON and deserializes correctly', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final payload = PairingPayload(
        hubId: 'hub-123',
        name: 'PC-Rumah',
        addresses: ['192.168.1.50'],
        port: 47820,
        fingerprint: 'sha256:abc',
        userId: 'user-xyz',
        token: 'token-secret',
        expiresAt: now + 120,
      );

      final jsonStr = payload.toJsonString();
      final restored = PairingPayload.fromJsonString(jsonStr);

      expect(restored.hubId, equals('hub-123'));
      expect(restored.name, equals('PC-Rumah'));
      expect(restored.addresses.first, equals('192.168.1.50'));
      expect(restored.port, equals(47820));
      expect(restored.token, equals('token-secret'));
      expect(restored.isExpired, isFalse);
    });

    test('Correctly identifies expired token', () {
      final pastEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 10;
      final expiredPayload = PairingPayload(
        hubId: 'hub-123',
        name: 'PC',
        addresses: ['127.0.0.1'],
        fingerprint: 'fp',
        userId: 'u',
        token: 'tok',
        expiresAt: pastEpoch,
      );

      expect(expiredPayload.isExpired, isTrue);
    });
  });

  group('LAN Sync Hub & Client Integration Tests', () {
    late DeviceDatabase hubDeviceDb;
    late WorkspaceDatabase hubWsDb;
    late MemoryWorkspaceManager hubWsManager;
    late SyncHubServer hubServer;

    late DeviceDatabase clientDeviceDb;
    late WorkspaceDatabase clientWsDb;
    late MemoryWorkspaceManager clientWsManager;
    late SyncClientEngine clientEngine;

    setUp(() async {
      hubDeviceDb = DeviceDatabase(NativeDatabase.memory());
      hubWsDb = WorkspaceDatabase(NativeDatabase.memory());
      hubWsManager = MemoryWorkspaceManager(deviceDb: hubDeviceDb, testWsDb: hubWsDb);

      hubServer = SyncHubServer(
        hubId: 'test-hub-id',
        hubName: 'Test-PC',
        workspaceManager: hubWsManager,
        deviceDb: hubDeviceDb,
      );

      clientDeviceDb = DeviceDatabase(NativeDatabase.memory());
      clientWsDb = WorkspaceDatabase(NativeDatabase.memory());
      clientWsManager = MemoryWorkspaceManager(deviceDb: clientDeviceDb, testWsDb: clientWsDb);

      clientEngine = SyncClientEngine(
        deviceDb: clientDeviceDb,
        workspaceManager: clientWsManager,
      );
    });

    tearDown(() async {
      await hubServer.stop();
      await hubDeviceDb.close();
      await hubWsDb.close();
      await clientDeviceDb.close();
      await clientWsDb.close();
    });

    test('Client can pair with Hub and synchronize changes over HTTP', () async {
      // 1. Start Hub server on an ephemeral free port (0)
      final port = await hubServer.start(port: 0);
      expect(hubServer.isRunning, isTrue);

      // 2. Create pairing session
      final pairingPayload = hubServer.createPairingSession(
        userId: 'user-01',
        localIps: ['127.0.0.1'],
      );

      // 3. Client pairs with Hub
      final pairSuccess = await clientEngine.pairWithHub(
        PairingPayload(
          hubId: pairingPayload.hubId,
          name: pairingPayload.name,
          addresses: ['127.0.0.1'],
          port: port,
          fingerprint: pairingPayload.fingerprint,
          userId: pairingPayload.userId,
          token: pairingPayload.token,
          expiresAt: pairingPayload.expiresAt,
        ),
        deviceId: 'mobile-client-01',
        deviceName: 'Pixel 9',
      );

      expect(pairSuccess, isTrue);

      // 4. Verify paired device is recorded on Hub
      final hubPaired = await hubDeviceDb.select(hubDeviceDb.pairedDevices).get();
      expect(hubPaired.length, equals(1));
      expect(hubPaired.first.deviceId, equals('mobile-client-01'));
      expect(hubPaired.first.name, equals('Pixel 9'));
    });
  });
}
