import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindea/core/database/device_database.dart';
import 'package:pindea/core/database/workspace_database.dart';
import 'package:pindea/features/notes/data/notes_repository.dart';
import 'package:pindea/features/notes/domain/models/block_item.dart';
import 'package:pindea/features/notes/domain/models/note_item.dart';
import 'package:pindea/features/notes/services/export_import_service.dart';


void main() {
  group('ExportImportService Tests', () {
    test('exportNoteToMarkdown generates valid formatted Markdown', () {
      final note = NoteItem(
        id: 'note-1',
        workspaceId: 'ws-1',
        title: 'Meeting Agenda',
        createdAt: DateTime(2026, 10, 7, 10, 0),
        updatedHlc: '1:0',
        blocks: [
          BlockItem(
            id: 'b-1',
            noteId: 'note-1',
            type: BlockType.heading,
            position: 'a0',
            content: 'Ringkasan Eksekutif',
            updatedHlc: '1:0',
          ),
          BlockItem(
            id: 'b-2',
            noteId: 'note-1',
            type: BlockType.text,
            position: 'a1',
            content: 'Ini adalah paragraf pengantar proyek.',
            updatedHlc: '1:0',
          ),
          BlockItem(
            id: 'b-3',
            noteId: 'note-1',
            type: BlockType.checklist,
            position: 'a2',
            content: 'Selesaikan desain',
            isDone: true,
            updatedHlc: '1:0',
          ),
          BlockItem(
            id: 'b-4',
            noteId: 'note-1',
            type: BlockType.checklist,
            position: 'a3',
            content: 'Deploy ke staging',
            isDone: false,
            updatedHlc: '1:0',
          ),
          BlockItem(
            id: 'b-5',
            noteId: 'note-1',
            type: BlockType.link,
            position: 'a4',
            content: 'Dokumentasi',
            url: 'https://pindea.app/docs',
            updatedHlc: '1:0',
          ),
        ],
      );

      final md = ExportImportService.exportNoteToMarkdown(note);

      expect(md, contains('title: "Meeting Agenda"'));
      expect(md, contains('# Meeting Agenda'));
      expect(md, contains('## Ringkasan Eksekutif'));
      expect(md, contains('Ini adalah paragraf pengantar proyek.'));
      expect(md, contains('- [x] Selesaikan desain'));
      expect(md, contains('- [ ] Deploy ke staging'));
      expect(md, contains('[Dokumentasi](https://pindea.app/docs)'));
    });

    test('exportWorkspaceToJson and parseNotesFromJson roundtrip successfully', () {
      final note = NoteItem(
        id: 'note-backup-1',
        workspaceId: 'ws-main',
        title: 'Catatan Backup',
        createdAt: DateTime(2026, 10, 7, 12, 0),
        updatedHlc: '1:0',
        blocks: [
          BlockItem(
            id: 'b-bk-1',
            noteId: 'note-backup-1',
            type: BlockType.text,
            position: 'a0',
            content: 'Konten penting',
            updatedHlc: '1:0',
          ),
        ],
      );

      final jsonString = ExportImportService.exportWorkspaceToJson(
        workspaceId: 'ws-main',
        notes: [note],
      );

      expect(jsonString, contains('pindea_backup_version'));
      expect(jsonString, contains('Catatan Backup'));

      final parsed = ExportImportService.parseNotesFromJson(jsonString);
      expect(parsed.length, 1);
      expect(parsed.first['title'], 'Catatan Backup');
      expect((parsed.first['blocks'] as List).length, 1);
    });
  });

  group('Trash & Soft Delete Lifecycle Tests', () {
    late DeviceDatabase deviceDb;
    late WorkspaceDatabase workspaceDb;
    late NotesRepository repository;

    setUp(() async {
      deviceDb = DeviceDatabase(NativeDatabase.memory());
      workspaceDb = WorkspaceDatabase(NativeDatabase.memory());
      repository = NotesRepository(
        deviceDb: deviceDb,
        workspaceDb: workspaceDb,
        deviceId: 'test-device-1',
      );
    });

    tearDown(() async {
      await deviceDb.close();
      await workspaceDb.close();
    });

    test('Full soft delete, trash stream, restore, and permanent delete lifecycle', () async {
      const wsId = 'ws-test';
      const userId = 'usr-test';

      // 1. Create note
      final note = await repository.createNote(
        workspaceId: wsId,
        userId: userId,
        title: 'Catatan Mau Dihapus',
        initialBlockContent: 'Teks uji coba',
      );

      // Verify note is active
      var activeNotes = await repository.watchNotes(wsId, userId).first;
      expect(activeNotes.length, 1);
      var trashNotes = await repository.watchTrashNotes(wsId, userId).first;
      expect(trashNotes.isEmpty, isTrue);

      // 2. Soft delete note
      await repository.deleteNote(wsId, note.id);

      // Verify note moved to trash
      activeNotes = await repository.watchNotes(wsId, userId).first;
      expect(activeNotes.isEmpty, isTrue);
      trashNotes = await repository.watchTrashNotes(wsId, userId).first;
      expect(trashNotes.length, 1);
      expect(trashNotes.first.id, note.id);

      // 3. Restore note
      await repository.restoreNote(wsId, note.id);

      activeNotes = await repository.watchNotes(wsId, userId).first;
      expect(activeNotes.length, 1);
      expect(activeNotes.first.id, note.id);
      trashNotes = await repository.watchTrashNotes(wsId, userId).first;
      expect(trashNotes.isEmpty, isTrue);

      // 4. Soft delete again and then permanently delete
      await repository.deleteNote(wsId, note.id);
      await repository.permanentlyDeleteNote(wsId, note.id);

      activeNotes = await repository.watchNotes(wsId, userId).first;
      expect(activeNotes.isEmpty, isTrue);
      trashNotes = await repository.watchTrashNotes(wsId, userId).first;
      expect(trashNotes.isEmpty, isTrue);
    });
  });
}
