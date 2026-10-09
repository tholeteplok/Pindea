import 'dart:convert';

/// 6 Supported Block Types in Pindea V1.0 (PRD Scope)
enum BlockType {
  text,
  heading,
  checklist,
  bullet,
  image,
  link;

  static BlockType fromString(String val) {
    return BlockType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => BlockType.text,
    );
  }
}

/// Domain Model for a Modular Block inside a Note
class BlockItem {
  final String id;
  final String noteId;
  final BlockType type;
  final String position; // Lexicographical fractional index string
  final String content; // Plain text or JSON payload
  final bool isDone; // Checklist status
  final String? url; // Link URL
  final String updatedHlc;

  const BlockItem({
    required this.id,
    required this.noteId,
    required this.type,
    required this.position,
    required this.content,
    this.isDone = false,
    this.url,
    required this.updatedHlc,
  });

  /// Parse block from Drift row and payload
  factory BlockItem.fromRaw({
    required String id,
    required String noteId,
    required String typeStr,
    required String position,
    required String rawContent,
    required String updatedHlc,
  }) {
    final type = BlockType.fromString(typeStr);
    bool isDone = false;
    String textContent = rawContent;
    String? linkUrl;

    if (type == BlockType.checklist) {
      try {
        if (rawContent.startsWith('{')) {
          final map = jsonDecode(rawContent) as Map<String, dynamic>;
          isDone = map['done'] == true;
          textContent = map['text'] as String? ?? '';
        }
      } catch (_) {
        // Fallback plain text
      }
    } else if (type == BlockType.link) {
      try {
        if (rawContent.startsWith('{')) {
          final map = jsonDecode(rawContent) as Map<String, dynamic>;
          linkUrl = map['url'] as String?;
          textContent = map['title'] as String? ?? '';
        }
      } catch (_) {}
    } else if (type == BlockType.image) {
      try {
        if (rawContent.startsWith('{')) {
          final map = jsonDecode(rawContent) as Map<String, dynamic>;
          linkUrl = map['url'] as String? ?? map['path'] as String?;
          textContent = map['caption'] as String? ?? '';
        } else {
          linkUrl = rawContent;
        }
      } catch (_) {
        linkUrl = rawContent;
      }
    }

    return BlockItem(
      id: id,
      noteId: noteId,
      type: type,
      position: position,
      content: textContent,
      isDone: isDone,
      url: linkUrl,
      updatedHlc: updatedHlc,
    );
  }

  /// Serialize content to store in SQLite
  String toRawContent() {
    if (type == BlockType.checklist) {
      return jsonEncode({'text': content, 'done': isDone});
    } else if (type == BlockType.link) {
      return jsonEncode({'title': content, 'url': url ?? ''});
    } else if (type == BlockType.image) {
      return jsonEncode({'url': url ?? content, 'caption': content});
    }
    return content;
  }

  BlockItem copyWith({
    String? content,
    String? position,
    bool? isDone,
    String? url,
    String? updatedHlc,
  }) {
    return BlockItem(
      id: id,
      noteId: noteId,
      type: type,
      position: position ?? this.position,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      url: url ?? this.url,
      updatedHlc: updatedHlc ?? this.updatedHlc,
    );
  }
}
