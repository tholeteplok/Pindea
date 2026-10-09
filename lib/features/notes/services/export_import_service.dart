import 'dart:convert';
import '../domain/models/block_item.dart';
import '../domain/models/note_item.dart';

/// Service for exporting and importing notes in Markdown and JSON formats.
class ExportImportService {
  /// Converts a single note into standard Markdown format with YAML frontmatter
  static String exportNoteToMarkdown(NoteItem note) {
    final buffer = StringBuffer();

    // Frontmatter metadata
    buffer.writeln('---');
    buffer.writeln('title: "${note.title.replaceAll('"', r'\"')}"');
    buffer.writeln('created_at: "${note.createdAt.toIso8601String()}"');
    if (note.colorCode != null) {
      buffer.writeln('color: "${note.colorCode}"');
    }
    buffer.writeln('---');
    buffer.writeln();

    // Note Title as Markdown H1
    buffer.writeln('# ${note.title}');
    buffer.writeln();

    // Serialize each block in order
    for (final block in note.blocks) {
      switch (block.type) {
        case BlockType.heading:
          buffer.writeln('## ${block.content}');
          buffer.writeln();
          break;
        case BlockType.checklist:
          final check = block.isDone ? '[x]' : '[ ]';
          buffer.writeln('- $check ${block.content}');
          break;
        case BlockType.bullet:
          buffer.writeln('- ${block.content}');
          break;
        case BlockType.link:
          final url = block.url ?? '';
          final text = block.content.isNotEmpty ? block.content : url;
          buffer.writeln('[$text]($url)');
          buffer.writeln();
          break;
        case BlockType.image:
          final url = block.url ?? '';
          final alt = block.content.isNotEmpty ? block.content : 'Image';
          buffer.writeln('![$alt]($url)');
          buffer.writeln();
          break;
        case BlockType.text:
          buffer.writeln(block.content);
          buffer.writeln();
          break;
      }
    }

    return buffer.toString().trim();
  }

  /// Exports an entire workspace's notes list to JSON backup format
  static String exportWorkspaceToJson({
    required String workspaceId,
    required List<NoteItem> notes,
  }) {
    final data = {
      'pindea_backup_version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'workspace_id': workspaceId,
      'total_notes': notes.length,
      'notes': notes.map((n) {
        return {
          'id': n.id,
          'title': n.title,
          'folder_id': n.folderId,
          'created_at': n.createdAt.toIso8601String(),
          'updated_hlc': n.updatedHlc,
          'is_pinned': n.isPinned,
          'color_code': n.colorCode,
          'blocks': n.blocks.map((b) {
            return {
              'id': b.id,
              'type': b.type.name,
              'position': b.position,
              'content': b.content,
              'is_done': b.isDone,
              'url': b.url,
            };
          }).toList(),
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Parses JSON backup data and returns a list of notes to import
  static List<Map<String, dynamic>> parseNotesFromJson(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('notes')) {
      throw const FormatException('Format backup Pindea tidak valid.');
    }

    final rawNotes = decoded['notes'] as List<dynamic>;
    return rawNotes.cast<Map<String, dynamic>>();
  }
}
