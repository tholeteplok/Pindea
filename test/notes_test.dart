import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindea/core/database/device_database.dart';
import 'package:pindea/core/database/workspace_database.dart';
import 'package:pindea/core/utils/fractional_index.dart';
import 'package:pindea/features/notes/data/notes_repository.dart';
import 'package:pindea/features/notes/domain/models/block_item.dart';

void main() {
  group('FractionalIndex Tests', () {
    test('Generates initial and subsequent positions in lexicographical order', () {
      final p0 = FractionalIndex.initialPosition();
      final p1 = FractionalIndex.after(p0);
      final pBetween = FractionalIndex.between(p0, p1);

      expect(p0.compareTo(pBetween), lessThan(0));
      expect(pBetween.compareTo(p1), lessThan(0));
    });

    test('Can insert before initial position', () {
      final p0 = FractionalIndex.initialPosition();
      final pBefore = FractionalIndex.before(p0);

      expect(pBefore.compareTo(p0), lessThan(0));
    });
  });

  group('BlockItem Domain Model Tests', () {
    test('Correctly serializes and deserializes checklist block with done status', () {
      const block = BlockItem(
        id: 'b1',
        noteId: 'n1',
        type: BlockType.checklist,
        position: 'a0',
        content: 'Beli Telur',
        isDone: true,
        updatedHlc: '100:0:device',
      );

      final raw = block.toRawContent();
      expect(raw, contains('"done":true'));
      expect(raw, contains('"text":"Beli Telur"'));

      final parsed = BlockItem.fromRaw(
        id: 'b1',
        noteId: 'n1',
        typeStr: 'checklist',
        position: 'a0',
        rawContent: raw,
        updatedHlc: '100:0:device',
      );

      expect(parsed.isDone, isTrue);
      expect(parsed.content, equals('Beli Telur'));
    });
  });

  group('NotesRepository Integration Tests', () {
    late DeviceDatabase deviceDb;
    late WorkspaceDatabase workspaceDb;
    late NotesRepository repository;

    setUp(() {
      deviceDb = DeviceDatabase(NativeDatabase.memory());
      workspaceDb = WorkspaceDatabase(NativeDatabase.memory());
      repository = NotesRepository(
        deviceDb: deviceDb,
        workspaceDb: workspaceDb,
        deviceId: 'test-device',
      );
    });

    tearDown(() async {
      await deviceDb.close();
      await workspaceDb.close();
    });

    test('Can create note, add blocks with fractional indexing, and toggle pin', () async {
      // 1. Create note
      final note = await repository.createNote(
        workspaceId: 'ws-1',
        userId: 'user-1',
        title: 'Catatan Rapat',
        initialBlockContent: 'Paragraf awal',
      );

      expect(note.title, equals('Catatan Rapat'));
      expect(note.blocks.length, equals(1));
      expect(note.blocks.first.content, equals('Paragraf awal'));

      // 2. Add block (Heading)
      final headingBlock = await repository.addBlock(
        'ws-1',
        note.id,
        BlockType.heading,
        content: 'Agenda Pembahasan',
      );

      expect(headingBlock.type, equals(BlockType.heading));
      expect(headingBlock.position.compareTo(note.blocks.first.position), greaterThan(0));

      // 3. Toggle pin for this user
      await repository.togglePin('user-1', note.id, true, colorCode: 'yellow');
      final fetched = await repository.getNoteById('ws-1', 'user-1', note.id);

      expect(fetched, isNotNull);
      expect(fetched!.isPinned, isTrue);
      expect(fetched.colorCode, equals('yellow'));
      expect(fetched.blocks.length, equals(2));

      // 4. Soft delete note
      await repository.deleteNote('ws-1', note.id);
      final afterDelete = await repository.getNoteById('ws-1', 'user-1', note.id);
      expect(afterDelete, isNull);
    });
  });
}
