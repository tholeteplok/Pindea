import 'block_item.dart';

/// Domain Model for a Note in Pindea
class NoteItem {
  final String id;
  final String workspaceId;
  final String? folderId;
  final String title;
  final DateTime createdAt;
  final String updatedHlc;
  final DateTime? deletedAt;
  final List<BlockItem> blocks;

  // Personal visual preferences (stored per-user in user_note_preferences)
  final bool isPinned;
  final String? pinOrder;
  final String? colorCode; // e.g. 'yellow', 'green', 'blue'
  final String? viewMode; // 'grid' or 'list'

  const NoteItem({
    required this.id,
    required this.workspaceId,
    this.folderId,
    required this.title,
    required this.createdAt,
    required this.updatedHlc,
    this.deletedAt,
    this.blocks = const [],
    this.isPinned = false,
    this.pinOrder,
    this.colorCode,
    this.viewMode,
  });

  NoteItem copyWith({
    String? title,
    String? folderId,
    String? updatedHlc,
    DateTime? deletedAt,
    List<BlockItem>? blocks,
    bool? isPinned,
    String? pinOrder,
    String? colorCode,
    String? viewMode,
  }) {
    return NoteItem(
      id: id,
      workspaceId: workspaceId,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedHlc: updatedHlc ?? this.updatedHlc,
      deletedAt: deletedAt ?? this.deletedAt,
      blocks: blocks ?? this.blocks,
      isPinned: isPinned ?? this.isPinned,
      pinOrder: pinOrder ?? this.pinOrder,
      colorCode: colorCode ?? this.colorCode,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  /// Get plain text snippet summary from blocks (first 2 lines)
  String get snippetSummary {
    if (blocks.isEmpty) return 'Catatan kosong...';
    final nonHeading = blocks.where((b) => b.type != BlockType.heading).toList();
    if (nonHeading.isNotEmpty) {
      return nonHeading.map((b) => b.content).take(2).join('\n');
    }
    return blocks.first.content;
  }
}
