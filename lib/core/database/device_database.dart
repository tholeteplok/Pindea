import 'package:drift/drift.dart';

part 'device_database.g.dart';

// --- TABLE DEFINITIONS FOR DEVICE DATABASE (app_device.db) ---

/// Local User Profiles on this device
class LocalUsers extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get pinVerifier => text().nullable()();
  TextColumn get pinSalt => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Paired Devices (Desktop Hub & Android Clients)
class PairedDevices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get name => text()();
  TextColumn get platform => text()();
  TextColumn get publicKey => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get pairedAt => dateTime()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

/// Workspaces Registry (Private and Shared)
class Workspaces extends Table {
  TextColumn get workspaceId => text()();
  TextColumn get type => text()(); // 'private' or 'shared'
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(false))();
  IntColumn get keyVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {workspaceId};
}

/// Personal Note Preferences (Per-user visual overrides: pin, color, view_mode)
/// CRITICAL: Separated from shared notes to prevent visual overwriting across members!
class UserNotePreferences extends Table {
  TextColumn get userId => text()();
  TextColumn get noteId => text()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get pinOrder => text().nullable()(); // Fractional index string
  TextColumn get colorCode => text().nullable()(); // Quick Note pastel code (e.g. 'yellow')
  TextColumn get viewMode => text().nullable()(); // 'grid' or 'list'

  @override
  Set<Column> get primaryKey => {userId, noteId};
}

/// App Key-Value Settings
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  LocalUsers,
  PairedDevices,
  Workspaces,
  UserNotePreferences,
  AppSettings,
])
class DeviceDatabase extends _$DeviceDatabase {
  DeviceDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
