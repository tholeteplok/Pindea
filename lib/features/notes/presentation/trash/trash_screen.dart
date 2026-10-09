import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/database/providers/database_providers.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_dimensions.dart';
import '../../../../core/theme/tokens/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../domain/models/note_item.dart';
import '../../providers/notes_providers.dart';

/// Screen displaying soft-deleted notes with Restore and Permanent Delete options
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trashNotesAsync = ref.watch(trashNotesStreamProvider);
    final activeWsId = ref.watch(activeWorkspaceIdProvider);

    return AppScaffold(
      header: AppHeader(
        title: 'Sampah',
        subtitle: 'Catatan yang dihapus sementara',
        leading: AppButton.icon(
          icon: PhosphorIcons.arrowLeft(),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          trashNotesAsync.maybeWhen(
            data: (notes) => notes.isNotEmpty
                ? AppButton.icon(
                    icon: PhosphorIcons.trashSimple(),
                    tooltip: 'Kosongkan Sampah',
                    color: AppColors.destructive(isDark: isDark),
                    onPressed: () => _confirmEmptyTrash(context, ref, activeWsId),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: trashNotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Gagal memuat catatan sampah: $err',
            style: AppTypography.bodySmall(isDark: isDark),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.trash(),
                    size: 64,
                    color: AppColors.textMuted(isDark: isDark),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'Kotak sampah kosong',
                    style: AppTypography.headingSmall(isDark: isDark),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    'Catatan yang dihapus akan muncul di sini',
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(
              left: AppDimensions.space16,
              right: AppDimensions.space16,
              bottom: AppDimensions.space32,
            ),
            itemCount: notes.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space12),
            itemBuilder: (context, index) {
              final note = notes[index];
              return _TrashNoteCard(
                note: note,
                isDark: isDark,
                onRestore: () => _restoreNote(context, ref, activeWsId, note.id),
                onPermanentDelete: () => _confirmPermanentDelete(context, ref, activeWsId, note.id, note.title),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _restoreNote(
    BuildContext context,
    WidgetRef ref,
    String? workspaceId,
    String noteId,
  ) async {
    final repo = await ref.read(notesRepositoryProvider.future);
    if (repo != null && workspaceId != null) {
      await repo.restoreNote(workspaceId, noteId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil dipulihkan'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _confirmPermanentDelete(
    BuildContext context,
    WidgetRef ref,
    String? workspaceId,
    String noteId,
    String title,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Hapus Permanen?',
      message: 'Catatan "$title" akan dihapus secara permanen dan tidak dapat dipulihkan kembali.',
      confirmLabel: 'Hapus Selamanya',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final repo = await ref.read(notesRepositoryProvider.future);
      if (repo != null && workspaceId != null) {
        await repo.permanentlyDeleteNote(workspaceId, noteId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan telah dihapus secara permanen'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmEmptyTrash(
    BuildContext context,
    WidgetRef ref,
    String? workspaceId,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Kosongkan Sampah?',
      message: 'Semua catatan di dalam sampah akan dihapus secara permanen dan tidak dapat dikembalikan.',
      confirmLabel: 'Kosongkan',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final repo = await ref.read(notesRepositoryProvider.future);
      if (repo != null && workspaceId != null) {
        await repo.emptyTrash(workspaceId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua catatan sampah telah dibersihkan'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}

/// Card representation of a deleted note
class _TrashNoteCard extends StatelessWidget {
  final NoteItem note;
  final bool isDark;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  const _TrashNoteCard({
    required this.note,
    required this.isDark,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final snippet = note.blocks.isNotEmpty ? note.blocks.first.content : 'Catatan kosong';
    final deletedDateStr = note.deletedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(note.deletedAt!)
        : 'Baru saja';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title.isNotEmpty ? note.title : 'Tanpa Judul',
                  style: AppTypography.headingSmall(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Dihapus: $deletedDateStr',
                style: AppTypography.code(isDark: isDark).copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            snippet,
            style: AppTypography.bodySmall(isDark: isDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.secondary(
                label: 'Pulihkan',
                icon: PhosphorIcons.arrowCounterClockwise(),
                onPressed: onRestore,
              ),
              const SizedBox(width: AppDimensions.space8),
              AppButton.secondary(
                label: 'Hapus Permanen',
                icon: PhosphorIcons.trash(),
                onPressed: onPermanentDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
