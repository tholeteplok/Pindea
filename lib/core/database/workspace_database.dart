import 'package:drift/drift.dart';

part 'workspace_database.g.dart';

// --- TABLE DEFINITIONS FOR WORKSPACE DATABASE (workspace_<id>.db) ---

/// Folders for hierarchical organization within a workspace
class Folders extends Table {
  TextColumn get folderId => text()();
  TextColumn get workspaceId => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {folderId};
}

/// Notes metadata and core content identification
class Notes extends Table {
  TextColumn get noteId => text()();
  TextColumn get workspaceId => text()();
  TextColumn get folderId => text().nullable()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedHlc => text()(); // Hybrid Logical Clock string
  DateTimeColumn get deletedAt => dateTime().nullable()(); // Soft delete tombstone

  @override
  Set<Column> get primaryKey => {noteId};
}

/// Blocks representing modular content inside a note
class Blocks extends Table {
  TextColumn get blockId => text()();
  TextColumn get noteId => text()();
  TextColumn get type => text()(); // 'text', 'heading', 'checklist', 'bullet', 'image', 'link'
  TextColumn get position => text()(); // Fractional index (LexoRank string)
  TextColumn get content => text()(); // Block content (Text string or JSON payload)
  TextColumn get updatedHlc => text()(); // Hybrid Logical Clock string
  DateTimeColumn get deletedAt => dateTime().nullable()(); // Soft delete tombstone

  @override
  Set<Column> get primaryKey => {blockId};
}

/// Tags for cross-folder categorization
class Tags extends Table {
  TextColumn get tagId => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {tagId};
}

/// Many-to-Many relationship between Notes and Tags
class NoteTags extends Table {
  TextColumn get noteId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

/// Attachments associated with notes and blocks
class Attachments extends Table {
  TextColumn get attachmentId => text()();
  TextColumn get noteId => text()();
  TextColumn get blockId => text().nullable()();
  TextColumn get path => text()();
  TextColumn get mime => text()();
  IntColumn get size => integer()();
  TextColumn get hash => text()(); // SHA-256 hash for deduplication and integrity

  @override
  Set<Column> get primaryKey => {attachmentId};
}

/// Operation Log for Block-Level LAN Sync
class SyncChanges extends Table {
  TextColumn get changeId => text()();
  TextColumn get workspaceId => text()();
  TextColumn get deviceId => text()();
  TextColumn get hlc => text()(); // Hybrid Logical Clock of this operation
  TextColumn get entityType => text()(); // 'note', 'block', 'folder', 'tag'
  TextColumn get entityId => text()();
  TextColumn get op => text()(); // 'upsert', 'delete'
  TextColumn get payload => text()(); // Serialized change payload (JSON)
  IntColumn get seq => integer().autoIncrement()(); // Local monotonically increasing sequence
}

/// Sync cursors tracking replication progress with peers
class SyncCursors extends Table {
  TextColumn get peerDeviceId => text()();
  TextColumn get workspaceId => text()();
  IntColumn get lastPulledSeq => integer().withDefault(const Constant(0))();
  IntColumn get lastPushedSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {peerDeviceId, workspaceId};
}

@DriftDatabase(tables: [
  Folders,
  Notes,
  Blocks,
  Tags,
  NoteTags,
  Attachments,
  SyncChanges,
  SyncCursors,
])
class WorkspaceDatabase extends _$WorkspaceDatabase {
  WorkspaceDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
