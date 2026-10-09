import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Database Connection Factory for Pindea
/// Manages physical SQLite file paths and optional SQLCipher encryption pragma.
class DatabaseConnectionFactory {
  DatabaseConnectionFactory._();

  /// Create a LazyDatabase connection targeting a specific SQLite file
  static QueryExecutor createConnection(
    String databaseName, {
    String? encryptionKey,
    bool logStatements = false,
  }) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final pindeaDir = Directory(p.join(dbFolder.path, 'Pindea', 'databases'));

      if (!await pindeaDir.exists()) {
        await pindeaDir.create(recursive: true);
      }

      final file = File(p.join(pindeaDir.path, databaseName));

      return NativeDatabase.createInBackground(
        file,
        logStatements: logStatements,
        setup: (rawDb) {
          // If encryptionKey is provided, execute SQLCipher key pragma
          if (encryptionKey != null && encryptionKey.isNotEmpty) {
            final escapedKey = encryptionKey.replaceAll("'", "''");
            rawDb.execute("PRAGMA key = '$escapedKey';");
          }
          // Enable WAL mode and foreign keys for high reliability and performance
          rawDb.execute('PRAGMA journal_mode = WAL;');
          rawDb.execute('PRAGMA foreign_keys = ON;');
        },
      );
    });
  }
}
