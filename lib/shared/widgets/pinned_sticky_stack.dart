import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../features/notes/domain/models/block_item.dart';
import '../../features/notes/domain/models/note_item.dart';

/// Centralized Stacked Sticky Notes Component
/// Emulates physical sticky notes stacked on top of each other with a top-center pushpin.
class PinnedStickyStack extends StatelessWidget {
  final List<NoteItem> notes;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<NoteItem> onTapNote;
  final void Function(NoteItem note, BlockItem block)? onToggleChecklist;

  const PinnedStickyStack({
    super.key,
    required this.notes,
    required this.activeIndex,
    required this.onIndexChanged,
    required this.onTapNote,
    this.onToggleChecklist,
  });

  Color _resolveNoteColor(String? colorCode, bool isDark) {
    if (colorCode == null) {
      return QuickNoteColor.yellow.getColor(isDark: isDark);
    }
    final match = QuickNoteColor.values.firstWhere(
      (c) => c.name.toLowerCase() == colorCode.toLowerCase(),
      orElse: () => QuickNoteColor.yellow,
    );
    return match.getColor(isDark: isDark);
  }

  Color _resolveTextColor(bool isDark) {
    return isDark ? AppColors.darkTextPrimary : const Color(0xFF1F1F1F);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (notes.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    final safeIndex = activeIndex.clamp(0, notes.length - 1);
    final activeNote = notes[safeIndex];

    // Determine notes for visual stack peeking behind
    final hasSecond = notes.length > 1;
    final secondNote = hasSecond ? notes[(safeIndex + 1) % notes.length] : null;
    final hasThird = notes.length > 2;
    final thirdNote = hasThird ? notes[(safeIndex + 2) % notes.length] : null;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (notes.length <= 1) return;
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -150) {
          // Swipe Left -> Next Note
          onIndexChanged((safeIndex + 1) % notes.length);
        } else if (velocity > 150) {
          // Swipe Right -> Prev Note
          onIndexChanged((safeIndex - 1 + notes.length) % notes.length);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 3rd Backing Note (peeking to the left-bottom)
          if (hasThird && thirdNote != null)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Transform.rotate(
                angle: -0.035, // ~ -2 degrees
                child: _buildBackingCard(
                  color: _resolveNoteColor(thirdNote.colorCode, isDark),
                  isDark: isDark,
                ),
              ),
            ),

          // 2nd Backing Note (peeking to the right-bottom)
          if (hasSecond && secondNote != null)
            Positioned(
              top: 6,
              left: 8,
              right: 8,
              child: Transform.rotate(
                angle: 0.03, // ~ +1.7 degrees
                child: _buildBackingCard(
                  color: _resolveNoteColor(secondNote.colorCode, isDark),
                  isDark: isDark,
                ),
              ),
            ),

          // 1st Foreground Active Note
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildActiveCard(
              context: context,
              note: activeNote,
              currentIndex: safeIndex,
              totalCount: notes.length,
              isDark: isDark,
            ),
          ),

          // Top Center Physical Pushpin
          Positioned(
            top: 0,
            child: _buildPhysicalPushpin(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBackingCard({required Color color, required bool isDark}) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : color.withValues(alpha: 0.8),
          width: AppDimensions.borderWidthThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard({
    required BuildContext context,
    required NoteItem note,
    required int currentIndex,
    required int totalCount,
    required bool isDark,
  }) {
    final noteColor = _resolveNoteColor(note.colorCode, isDark);
    final textColor = _resolveTextColor(isDark);
    final borderColor = isDark ? AppColors.darkOutline : const Color(0xFFE0D768);

    return Material(
      color: noteColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: borderColor,
          width: AppDimensions.borderWidthThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTapNote(note),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.cardPadding,
            AppDimensions.space16 + AppDimensions.space4,
            AppDimensions.cardPadding,
            AppDimensions.cardPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Title & Page Indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : 'Catatan Tanpa Judul',
                      style: AppTypography.headingSmall(isDark: false).copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  // Counter 1/4
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space8,
                      vertical: AppDimensions.space2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      '${currentIndex + 1}/$totalCount',
                      style: AppTypography.monoLabel(isDark: false).copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Blocks Content / Checklist Preview
              if (note.blocks.isEmpty)
                Text(
                  'Catatan ini masih kosong.',
                  style: AppTypography.bodySmall(isDark: false).copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...note.blocks.take(3).map((block) {
                  if (block.type == BlockType.checklist) {
                    return _buildInteractiveChecklistItem(
                      note: note,
                      block: block,
                      textColor: textColor,
                      isDark: isDark,
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (block.type == BlockType.bullet)
                          Padding(
                            padding: const EdgeInsets.only(right: 6, top: 1),
                            child: Text('•', style: TextStyle(color: textColor, fontSize: 13)),
                          ),
                        Expanded(
                          child: Text(
                            block.content.isNotEmpty ? block.content : '(Tanpa isi)',
                            style: AppTypography.bodySmall(isDark: false).copyWith(
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveChecklistItem({
    required NoteItem note,
    required BlockItem block,
    required Color textColor,
    required bool isDark,
  }) {
    final isDone = block.isDone;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rounded Custom Checkbox
          InkWell(
            onTap: onToggleChecklist != null ? () => onToggleChecklist!(note, block) : null,
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF2E7D32) : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDone ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
                  width: 1.4,
                ),
              ),
              child: isDone
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          // Checklist text
          Expanded(
            child: Text(
              block.content,
              style: AppTypography.bodySmall(isDark: false).copyWith(
                color: isDone ? textColor.withValues(alpha: 0.55) : textColor,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalPushpin(bool isDark) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E1E),
        border: Border.all(
          color: const Color(0xFF383838),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4A4A4A),
            gradient: const RadialGradient(
              colors: [Color(0xFF757575), Color(0xFF1F1F1F)],
              center: Alignment(-0.3, -0.3),
              radius: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final color = QuickNoteColor.yellow.getColor(isDark: isDark);
    final textColor = _resolveTextColor(isDark);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.cardPadding,
              AppDimensions.space20,
              AppDimensions.cardPadding,
              AppDimensions.cardPadding,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isDark ? AppColors.darkOutline : const Color(0xFFE0D768),
                width: AppDimensions.borderWidthThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pin catatan penting di sini',
                  style: AppTypography.headingSmall(isDark: false).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Ketuk ikon pin pada catatan mana saja untuk menampilkannya di tumpukan Quick Notes.',
                  style: AppTypography.bodySmall(isDark: false).copyWith(
                    color: textColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: _buildPhysicalPushpin(isDark),
        ),
      ],
    );
  }
}
