import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/crypto/hlc.dart';
import '../../../core/database/device_database.dart';
import '../../../core/database/workspace_database.dart';
import '../../../core/utils/fractional_index.dart';
import '../domain/models/block_item.dart';
import '../domain/models/note_item.dart';

/// Repository for Note CRUD operations, block editing, fractional indexing,
/// and personal user note preference management.
class NotesRepository {
  static const _uuid = Uuid();

  final DeviceDatabase deviceDb;
  final WorkspaceDatabase workspaceDb;
  final String deviceId;

  NotesRepository({
    required this.deviceDb,
    required this.workspaceDb,
    this.deviceId = 'local-device',
  });

  /// Stream of active notes in the workspace joined with the user's personal preferences
  Stream<List<NoteItem>> watchNotes(String workspaceId, String userId) {
    final notesQuery = (workspaceDb.select(workspaceDb.notes)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId) & tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();

    return notesQuery.asyncMap((notesList) async {
      final userPrefs = await (deviceDb.select(deviceDb.userNotePreferences)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      final prefMap = {for (var p in userPrefs) p.noteId: p};

      final results = <NoteItem>[];
      for (final n in notesList) {
        final pref = prefMap[n.noteId];
        final blocks = await _getBlocksForNote(n.noteId);

        results.add(
          NoteItem(
            id: n.noteId,
            workspaceId: n.workspaceId,
            folderId: n.folderId,
            title: n.title,
            createdAt: n.createdAt,
            updatedHlc: n.updatedHlc,
            deletedAt: n.deletedAt,
            blocks: blocks,
            isPinned: pref?.isPinned ?? false,
            pinOrder: pref?.pinOrder,
            colorCode: pref?.colorCode,
            viewMode: pref?.viewMode,
          ),
        );
      }
      return results;
    });
  }

  /// Watch pinned notes for the current user
  Stream<List<NoteItem>> watchPinnedNotes(String workspaceId, String userId) {
    return watchNotes(workspaceId, userId).map((notes) {
      return notes.where((n) => n.isPinned).toList();
    });
  }

  /// Get blocks for a specific note ordered by fractional index position
  Future<List<BlockItem>> _getBlocksForNote(String noteId) async {
    final rows = await (workspaceDb.select(workspaceDb.blocks)
          ..where((tbl) => tbl.noteId.equals(noteId) & tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]))
        .get();

    return rows
        .map(
          (r) => BlockItem.fromRaw(
            id: r.blockId,
            noteId: r.noteId,
            typeStr: r.type,
            position: r.position,
            rawContent: r.content,
            updatedHlc: r.updatedHlc,
          ),
        )
        .toList();
  }

  /// Get note details by ID
  Future<NoteItem?> getNoteById(String workspaceId, String userId, String noteId) async {
    final noteRows = await (workspaceDb.select(workspaceDb.notes)
          ..where((tbl) => tbl.noteId.equals(noteId) & tbl.deletedAt.isNull()))
        .get();

    if (noteRows.isEmpty) return null;
    final n = noteRows.first;

    final prefRows = await (deviceDb.select(deviceDb.userNotePreferences)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.noteId.equals(noteId)))
        .get();

    final pref = prefRows.isNotEmpty ? prefRows.first : null;
    final blocks = await _getBlocksForNote(noteId);

    return NoteItem(
      id: n.noteId,
      workspaceId: n.workspaceId,
      folderId: n.folderId,
      title: n.title,
      createdAt: n.createdAt,
      updatedHlc: n.updatedHlc,
      deletedAt: n.deletedAt,
      blocks: blocks,
      isPinned: pref?.isPinned ?? false,
      pinOrder: pref?.pinOrder,
      colorCode: pref?.colorCode,
      viewMode: pref?.viewMode,
    );
  }

  /// Create a new Note with an initial Text block (<1 second quick capture)
  Future<NoteItem> createNote({
    required String workspaceId,
    required String userId,
    String title = 'Catatan Baru',
    String? initialBlockContent,
    String? colorCode,
    bool isPinned = false,
  }) async {
    final noteId = _uuid.v4();
    final hlc = HLC.now(deviceId).pack();
    final now = DateTime.now();

    // 1. Insert note record
    await workspaceDb.into(workspaceDb.notes).insert(
          NotesCompanion.insert(
            noteId: noteId,
            workspaceId: workspaceId,
            title: title,
            createdAt: now,
            updatedHlc: hlc,
          ),
        );

    // 2. Insert initial text block
    final blockId = _uuid.v4();
    final blockPos = FractionalIndex.initialPosition();
    final content = initialBlockContent ?? '';

    await workspaceDb.into(workspaceDb.blocks).insert(
          BlocksCompanion.insert(
            blockId: blockId,
            noteId: noteId,
            type: 'text',
            position: blockPos,
            content: content,
            updatedHlc: hlc,
          ),
        );

    // 3. Insert personal preference (pin / color)
    if (isPinned || colorCode != null) {
      await deviceDb.into(deviceDb.userNotePreferences).insert(
            UserNotePreferencesCompanion.insert(
              userId: userId,
              noteId: noteId,
              isPinned: Value(isPinned),
              colorCode: Value(colorCode),
            ),
          );
    }

    // 4. Log change to sync operation log
    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'note',
            entityId: noteId,
            op: 'upsert',
            payload: jsonEncode({'title': title, 'created_at': now.toIso8601String()}),
          ),
        );

    final initialBlock = BlockItem(
      id: blockId,
      noteId: noteId,
      type: BlockType.text,
      position: blockPos,
      content: content,
      updatedHlc: hlc,
    );

    return NoteItem(
      id: noteId,
      workspaceId: workspaceId,
      title: title,
      createdAt: now,
      updatedHlc: hlc,
      blocks: [initialBlock],
      isPinned: isPinned,
      colorCode: colorCode,
    );
  }

  /// Update Note title
  Future<void> updateNoteTitle(String workspaceId, String noteId, String newTitle) async {
    final hlc = HLC.now(deviceId).pack();

    await (workspaceDb.update(workspaceDb.notes)..where((tbl) => tbl.noteId.equals(noteId))).write(
      NotesCompanion(
        title: Value(newTitle),
        updatedHlc: Value(hlc),
      ),
    );

    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'note',
            entityId: noteId,
            op: 'upsert',
            payload: jsonEncode({'title': newTitle}),
          ),
        );
  }

  /// Add a new block to a note with fractional indexing
  Future<BlockItem> addBlock(
    String workspaceId,
    String noteId,
    BlockType type, {
    String? content,
    String? url,
    bool isDone = false,
  }) async {
    final blockId = _uuid.v4();
    final hlc = HLC.now(deviceId).pack();

    final existingBlocks = await _getBlocksForNote(noteId);
    final String position;
    if (existingBlocks.isEmpty) {
      position = FractionalIndex.initialPosition();
    } else {
      position = FractionalIndex.after(existingBlocks.last.position);
    }

    final block = BlockItem(
      id: blockId,
      noteId: noteId,
      type: type,
      position: position,
      content: content ?? '',
      isDone: isDone,
      url: url,
      updatedHlc: hlc,
    );

    await workspaceDb.into(workspaceDb.blocks).insert(
          BlocksCompanion.insert(
            blockId: blockId,
            noteId: noteId,
            type: type.name,
            position: position,
            content: block.toRawContent(),
            updatedHlc: hlc,
          ),
        );

    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'block',
            entityId: blockId,
            op: 'upsert',
            payload: jsonEncode({
              'note_id': noteId,
              'type': type.name,
              'position': position,
              'content': block.toRawContent(),
            }),
          ),
        );

    return block;
  }

  /// Update an existing block
  Future<void> updateBlock(String workspaceId, BlockItem block) async {
    final hlc = HLC.now(deviceId).pack();

    await (workspaceDb.update(workspaceDb.blocks)..where((tbl) => tbl.blockId.equals(block.id))).write(
      BlocksCompanion(
        content: Value(block.toRawContent()),
        position: Value(block.position),
        updatedHlc: Value(hlc),
      ),
    );

    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'block',
            entityId: block.id,
            op: 'upsert',
            payload: jsonEncode({
              'content': block.toRawContent(),
              'position': block.position,
            }),
          ),
        );
  }

  /// Delete a block (Soft delete tombstone)
  Future<void> deleteBlock(String workspaceId, String blockId) async {
    final hlc = HLC.now(deviceId).pack();
    final now = DateTime.now();

    await (workspaceDb.update(workspaceDb.blocks)..where((tbl) => tbl.blockId.equals(blockId))).write(
      BlocksCompanion(
        deletedAt: Value(now),
        updatedHlc: Value(hlc),
      ),
    );

    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'block',
            entityId: blockId,
            op: 'delete',
            payload: jsonEncode({'block_id': blockId}),
          ),
        );
  }

  /// Toggle pin status for a note (Per-user preference)
  Future<void> togglePin(String userId, String noteId, bool isPinned, {String? colorCode}) async {
    await deviceDb.into(deviceDb.userNotePreferences).insertOnConflictUpdate(
          UserNotePreferencesCompanion(
            userId: Value(userId),
            noteId: Value(noteId),
            isPinned: Value(isPinned),
            colorCode: colorCode != null ? Value(colorCode) : const Value.absent(),
          ),
        );
  }

  /// Update color for a note (Per-user preference)
  Future<void> setNoteColor(String userId, String noteId, String colorCode) async {
    await deviceDb.into(deviceDb.userNotePreferences).insertOnConflictUpdate(
          UserNotePreferencesCompanion(
            userId: Value(userId),
            noteId: Value(noteId),
            colorCode: Value(colorCode),
          ),
        );
  }

  /// Soft delete a note (Move to Trash)
  Future<void> deleteNote(String workspaceId, String noteId) async {
    final hlc = HLC.now(deviceId).pack();
    final now = DateTime.now();

    await (workspaceDb.update(workspaceDb.notes)..where((tbl) => tbl.noteId.equals(noteId))).write(
      NotesCompanion(
        deletedAt: Value(now),
        updatedHlc: Value(hlc),
      ),
    );

    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'note',
            entityId: noteId,
            op: 'delete',
            payload: jsonEncode({'note_id': noteId}),
          ),
        );
  }

  /// Stream of trash (soft-deleted) notes in the workspace
  Stream<List<NoteItem>> watchTrashNotes(String workspaceId, String userId) {
    final trashQuery = (workspaceDb.select(workspaceDb.notes)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId) & tbl.deletedAt.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.deletedAt)]))
        .watch();

    return trashQuery.asyncMap((notesList) async {
      final userPrefs = await (deviceDb.select(deviceDb.userNotePreferences)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      final prefMap = {for (var p in userPrefs) p.noteId: p};

      final results = <NoteItem>[];
      for (final n in notesList) {
        final pref = prefMap[n.noteId];
        final blocks = await _getBlocksForNote(n.noteId);

        results.add(
          NoteItem(
            id: n.noteId,
            workspaceId: n.workspaceId,
            folderId: n.folderId,
            title: n.title,
            createdAt: n.createdAt,
            updatedHlc: n.updatedHlc,
            deletedAt: n.deletedAt,
            blocks: blocks,
            isPinned: pref?.isPinned ?? false,
            pinOrder: pref?.pinOrder,
            colorCode: pref?.colorCode,
            viewMode: pref?.viewMode,
          ),
        );
      }
      return results;
    });
  }

  /// Restore a soft-deleted note from trash
  Future<void> restoreNote(String workspaceId, String noteId) async {
    final hlc = HLC.now(deviceId).pack();

    await (workspaceDb.update(workspaceDb.notes)..where((tbl) => tbl.noteId.equals(noteId))).write(
      NotesCompanion(
        deletedAt: const Value(null),
        updatedHlc: Value(hlc),
      ),
    );

    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'note',
            entityId: noteId,
            op: 'upsert',
            payload: jsonEncode({'restored': true, 'note_id': noteId}),
          ),
        );
  }

  /// Permanently delete a note and its blocks (Hard delete)
  Future<void> permanentlyDeleteNote(String workspaceId, String noteId) async {
    final hlc = HLC.now(deviceId).pack();

    // 1. Delete associated blocks
    await (workspaceDb.delete(workspaceDb.blocks)..where((tbl) => tbl.noteId.equals(noteId))).go();

    // 2. Delete the note itself
    await (workspaceDb.delete(workspaceDb.notes)..where((tbl) => tbl.noteId.equals(noteId))).go();

    // 3. Delete user preferences for this note
    await (deviceDb.delete(deviceDb.userNotePreferences)..where((tbl) => tbl.noteId.equals(noteId))).go();

    // 4. Record permanent tombstone in syncChanges
    await workspaceDb.into(workspaceDb.syncChanges).insert(
          SyncChangesCompanion.insert(
            changeId: _uuid.v4(),
            workspaceId: workspaceId,
            deviceId: deviceId,
            hlc: hlc,
            entityType: 'note',
            entityId: noteId,
            op: 'permanent_delete',
            payload: jsonEncode({'permanent_delete': true, 'note_id': noteId}),
          ),
        );
  }

  /// Empty all notes currently in the trash
  Future<void> emptyTrash(String workspaceId) async {
    final trashNotes = await (workspaceDb.select(workspaceDb.notes)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId) & tbl.deletedAt.isNotNull()))
        .get();

    for (final note in trashNotes) {
      await permanentlyDeleteNote(workspaceId, note.noteId);
    }
  }
}

