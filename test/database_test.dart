import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindea/core/crypto/hlc.dart';
import 'package:pindea/core/crypto/pin_crypto.dart';
import 'package:pindea/core/database/device_database.dart';
import 'package:pindea/core/database/workspace_database.dart';

void main() {
  group('HLC (Hybrid Logical Clock) Tests', () {
    test('HLC generates valid string and orders monotonically', () {
      final hlc1 = HLC.now('node-A');
      final hlc2 = hlc1.tick();

      expect(hlc2.compareTo(hlc1), greaterThan(0));

      final packed = hlc2.pack();
      final unpacked = HLC.unpack(packed);

      expect(unpacked, equals(hlc2));
      expect(unpacked.nodeId, equals('node-A'));
    });

    test('HLC handles remote causal merge correctly', () {
      final localHlc = HLC(millis: 1000, counter: 5, nodeId: 'node-A');
      final remoteHlc = HLC(millis: 1000, counter: 10, nodeId: 'node-B');

      final merged = localHlc.receive(remoteHlc, 1000);
      expect(merged.counter, equals(11));
      expect(merged.nodeId, equals('node-A'));
    });
  });

  group('PinCrypto Tests', () {
    test('Verifies correct PIN and rejects incorrect PIN', () {
      const pin = '1234';
      const salt = 'random_salt_123';

      final hash = PinCrypto.hashPin(pin: pin, salt: salt);
      expect(PinCrypto.verifyPin(pin: pin, salt: salt, verifier: hash), isTrue);
      expect(PinCrypto.verifyPin(pin: '9999', salt: salt, verifier: hash), isFalse);
    });

    test('Derives key deterministically', () {
      final key1 = PinCrypto.deriveKey(pin: '5678', salt: 'salt_abc');
      final key2 = PinCrypto.deriveKey(pin: '5678', salt: 'salt_abc');
      expect(key1, equals(key2));
      expect(key1.length, equals(64)); // 256-bit hex string
    });
  });

  group('Drift Multi-Database Schema Tests', () {
    late DeviceDatabase deviceDb;
    late WorkspaceDatabase workspaceDb;

    setUp(() {
      deviceDb = DeviceDatabase(NativeDatabase.memory());
      workspaceDb = WorkspaceDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await deviceDb.close();
      await workspaceDb.close();
    });

    test('Device Database can store user and personal note preferences', () async {
      // 1. Insert user
      await deviceDb.into(deviceDb.localUsers).insert(
            LocalUsersCompanion.insert(
              userId: 'user-1',
              displayName: 'Fabian',
              createdAt: DateTime.now(),
            ),
          );

      // 2. Insert personal note preferences (prevents shared note visual overwrite)
      await deviceDb.into(deviceDb.userNotePreferences).insert(
            UserNotePreferencesCompanion.insert(
              userId: 'user-1',
              noteId: 'shared-note-99',
              isPinned: const Value(true),
              colorCode: const Value('yellow'),
            ),
          );

      final prefs = await (deviceDb.select(deviceDb.userNotePreferences)
            ..where((tbl) => tbl.userId.equals('user-1')))
          .get();

      expect(prefs.length, equals(1));
      expect(prefs.first.isPinned, isTrue);
      expect(prefs.first.colorCode, equals('yellow'));
    });

    test('Workspace Database can store note, blocks and track sync_changes', () async {
      final now = DateTime.now();
      final hlc = HLC.now('device-1').pack();

      // 1. Insert Note
      await workspaceDb.into(workspaceDb.notes).insert(
            NotesCompanion.insert(
              noteId: 'note-1',
              workspaceId: 'ws-1',
              title: 'Catatan Belanja',
              createdAt: now,
              updatedHlc: hlc,
            ),
          );

      // 2. Insert Block
      await workspaceDb.into(workspaceDb.blocks).insert(
            BlocksCompanion.insert(
              blockId: 'block-1',
              noteId: 'note-1',
              type: 'checklist',
              position: 'a0', // Fractional index
              content: 'Susu Almond',
              updatedHlc: hlc,
            ),
          );

      // 3. Insert Sync Change Log
      await workspaceDb.into(workspaceDb.syncChanges).insert(
            SyncChangesCompanion.insert(
              changeId: 'change-1',
              workspaceId: 'ws-1',
              deviceId: 'device-1',
              hlc: hlc,
              entityType: 'block',
              entityId: 'block-1',
              op: 'upsert',
              payload: '{"content":"Susu Almond"}',
            ),
          );

      final notes = await workspaceDb.select(workspaceDb.notes).get();
      final blocks = await workspaceDb.select(workspaceDb.blocks).get();
      final changes = await workspaceDb.select(workspaceDb.syncChanges).get();

      expect(notes.length, equals(1));
      expect(blocks.length, equals(1));
      expect(changes.length, equals(1));
      expect(changes.first.entityType, equals('block'));
    });
  });
}
