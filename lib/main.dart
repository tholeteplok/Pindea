import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'core/database/providers/database_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens/app_colors.dart';
import 'core/theme/tokens/app_dimensions.dart';
import 'core/theme/tokens/app_typography.dart';
import 'features/notes/domain/models/note_item.dart';
import 'features/notes/presentation/editor/note_editor_screen.dart';
import 'features/notes/providers/notes_providers.dart';

import 'features/notes/services/export_import_service.dart';
import 'features/sync/presentation/sync_status_sheet.dart';
import 'shared/widgets/app_bottom_sheet.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/app_card.dart';
import 'shared/widgets/app_chip.dart';
import 'shared/widgets/app_dialog.dart';
import 'shared/widgets/app_drawer.dart';
import 'shared/widgets/app_header.dart';
import 'shared/widgets/app_scaffold.dart';
import 'shared/widgets/pinned_sticky_stack.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PindeaApp());
}

class PindeaApp extends StatelessWidget {
  const PindeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Pindea',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const PindeaHomeScreen(),
      ),
    );
  }
}

class PindeaHomeScreen extends ConsumerStatefulWidget {
  const PindeaHomeScreen({super.key});

  @override
  ConsumerState<PindeaHomeScreen> createState() => _PindeaHomeScreenState();
}

class _PindeaHomeScreenState extends ConsumerState<PindeaHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  int _activePinnedCardIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createAndOpenNewNote() async {
    final repo = await ref.read(notesRepositoryProvider.future);
    final userId = await ref.read(currentUserIdProvider.future);
    final activeWsId = ref.read(activeWorkspaceIdProvider);

    if (repo != null && activeWsId != null) {
      final newNote = await repo.createNote(
        workspaceId: activeWsId,
        userId: userId,
        title: 'Catatan Baru',
      );
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteEditorScreen(noteId: newNote.id),
          ),
        );
      }
    }
  }

  void _showFilterSheet() {
    final activeFolder = ref.read(selectedFolderFilterProvider);

    AppBottomSheet.show(
      context: context,
      title: 'Filter Catatan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Berdasarkan Folder',
            style: AppTypography.headingSmall(isDark: Theme.of(context).brightness == Brightness.dark),
          ),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: [
              AppChip(
                label: 'Semua',
                isSelected: activeFolder == null || activeFolder == 'Semua',
                onTap: () {
                  ref.read(selectedFolderFilterProvider.notifier).state = null;
                  Navigator.of(context).pop();
                },
              ),
              ...['Personal', 'Work', 'Family'].map((f) => AppChip(
                    label: f,
                    isSelected: activeFolder == f,
                    onTap: () {
                      ref.read(selectedFolderFilterProvider.notifier).state = f;
                      Navigator.of(context).pop();
                    },
                  )),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),
          Text(
            'Berdasarkan Urutan',
            style: AppTypography.headingSmall(isDark: Theme.of(context).brightness == Brightness.dark),
          ),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: [
              AppChip(
                label: 'Terbaru',
                isSelected: ref.watch(noteSortOrderProvider) == 0,
                onTap: () {
                  ref.read(noteSortOrderProvider.notifier).state = 0;
                  Navigator.of(context).pop();
                },
              ),
              AppChip(
                label: 'Terlama',
                isSelected: ref.watch(noteSortOrderProvider) == 1,
                onTap: () {
                  ref.read(noteSortOrderProvider.notifier).state = 1;
                  Navigator.of(context).pop();
                },
              ),
              AppChip(
                label: 'Alfabetis (A-Z)',
                isSelected: ref.watch(noteSortOrderProvider) == 2,
                onTap: () {
                  ref.read(noteSortOrderProvider.notifier).state = 2;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    final notes = ref.read(filteredNotesProvider).value ?? [];
    final activeWsId = ref.read(activeWorkspaceIdProvider) ?? 'default';

    AppBottomSheet.show(
      context: context,
      title: 'Ekspor & Cadangan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pilih format penyimpanan atau cadangan catatan Anda:',
            style: AppTypography.bodySmall(isDark: Theme.of(context).brightness == Brightness.dark),
          ),
          const SizedBox(height: AppDimensions.space16),
          AppButton.secondary(
            label: 'Cadangkan Seluruh Workspace (JSON)',
            icon: PhosphorIcons.fileCode(),
            onPressed: () {
              Navigator.of(context).pop();
              final jsonString = ExportImportService.exportWorkspaceToJson(
                workspaceId: activeWsId,
                notes: notes,
              );
              AppDialog.showCustom(
                context: context,
                title: 'Cadangan JSON Berhasil Dibuat',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ukuran cadangan: ${jsonString.length} bytes (${notes.length} catatan)',
                      style: AppTypography.body(isDark: Theme.of(context).brightness == Brightness.dark),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    AppButton.primary(
                      label: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.space12),
          AppButton.secondary(
            label: 'Ekspor Catatan Pertama ke Markdown (.md)',
            icon: PhosphorIcons.markdownLogo(),
            onPressed: () {
              Navigator.of(context).pop();
              if (notes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak ada catatan untuk diekspor')),
                );
                return;
              }
              final mdString = ExportImportService.exportNoteToMarkdown(notes.first);
              AppDialog.showCustom(
                context: context,
                title: 'Pratinjau Markdown',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space8),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark: Theme.of(context).brightness == Brightness.dark),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        border: Border.all(
                          color: AppColors.border(isDark: Theme.of(context).brightness == Brightness.dark),
                        ),
                      ),
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        child: Text(
                          mdString,
                          style: AppTypography.code(isDark: Theme.of(context).brightness == Brightness.dark),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    AppButton.primary(
                      label: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );

            },
          ),
          const SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger initial DB setup if not yet ready
    ref.watch(currentWorkspaceDatabaseProvider);

    final filteredNotesAsync = ref.watch(filteredNotesProvider);
    final filteredPinnedNotesAsync = ref.watch(filteredPinnedNotesProvider);
    final sortOrder = ref.watch(noteSortOrderProvider);
    final isGridView = ref.watch(noteViewModeIsGridProvider);

    return AppScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(
        onExportTap: () => _showExportSheet(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAndOpenNewNote,
        backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        foregroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        icon: const PhosphorIcon(PhosphorIconsBold.plus, size: 18),
        label: Text(
          'Catatan Baru',
          style: AppTypography.buttonLabel(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. SEAMLESS APP HEADER (WITHOUT CARD BOX, NAKED ACTION ICONS)
          AppHeader(
            title: 'Pindea',
            subtitle: 'Personal',
            leading: AppButton.icon(
              icon: PhosphorIcons.list(),
              tooltip: 'Menu Utama',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            isSyncing: false,
            onSyncTap: () => SyncStatusSheet.show(context),
            onWorkspaceTap: () {},
          ),

          // 2. REAL-TIME SEARCH INPUT (SEAMLESS, NO SURROUNDING CARD)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenMargin,
              vertical: AppDimensions.space4,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(noteSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
              style: AppTypography.body(isDark: isDark),
              decoration: InputDecoration(
                hintText: 'Cari catatan atau isi...',
                hintStyle: AppTypography.bodySmall(isDark: isDark).copyWith(
                  color: AppColors.textMuted(isDark: isDark),
                ),
                prefixIcon: Icon(
                  PhosphorIcons.magnifyingGlass(),
                  size: 20,
                  color: AppColors.textMuted(isDark: isDark),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          PhosphorIcons.xCircle(),
                          size: 18,
                          color: AppColors.textMuted(isDark: isDark),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(noteSearchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface(isDark: isDark),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide: BorderSide(color: AppColors.border(isDark: isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide: BorderSide(color: AppColors.border(isDark: isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  borderSide: BorderSide(
                    color: AppColors.accent(isDark: isDark),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space8),

          // 3. QUICK NOTES SECTION HEADER
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenMargin,
              vertical: AppDimensions.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Notes',
                  style: AppTypography.headingSmall(isDark: isDark),
                ),
                filteredPinnedNotesAsync.when(
                  data: (pinned) => pinned.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            if (pinned.length > 1) {
                              setState(() {
                                _activePinnedCardIndex = (_activePinnedCardIndex + 1) % pinned.length;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space4,
                              vertical: AppDimensions.space2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${pinned.length} catatan',
                                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                                    color: AppColors.textMuted(isDark: isDark),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space4),
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: AppColors.textMuted(isDark: isDark),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // 4. QUICK NOTE STACKED STICKY NOTES (TERPUSAT DENGAN PIN FISIK)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenMargin,
              vertical: AppDimensions.space4,
            ),
            child: filteredPinnedNotesAsync.when(
              data: (pinnedList) {
                return PinnedStickyStack(
                  notes: pinnedList,
                  activeIndex: _activePinnedCardIndex,
                  onIndexChanged: (newIdx) {
                    setState(() {
                      _activePinnedCardIndex = newIdx;
                    });
                  },
                  onTapNote: (note) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(noteId: note.id),
                      ),
                    );
                  },
                  onToggleChecklist: (note, block) async {
                    final repo = await ref.read(notesRepositoryProvider.future);
                    if (repo != null) {
                      await repo.updateBlock(
                        note.workspaceId,
                        block.copyWith(isDone: !block.isDone),
                      );
                      ref.invalidate(pinnedNotesStreamProvider);
                      ref.invalidate(notesStreamProvider);
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // 5. ALL NOTES SECTION HEADER
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenMargin,
              vertical: AppDimensions.space8,
            ),
            child: Row(
              children: [
                Text(
                  'All Notes',
                  style: AppTypography.headingSmall(isDark: isDark),
                ),
                const Spacer(),
                // Toggle Grid View
                InkWell(
                  onTap: () => ref.read(noteViewModeIsGridProvider.notifier).state = true,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space4),
                    child: PhosphorIcon(
                      isGridView ? PhosphorIconsBold.squaresFour : PhosphorIconsRegular.squaresFour,
                      size: 20,
                      color: isGridView
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                // Toggle List View
                InkWell(
                  onTap: () => ref.read(noteViewModeIsGridProvider.notifier).state = false,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space4),
                    child: PhosphorIcon(
                      !isGridView ? PhosphorIconsBold.list : PhosphorIconsRegular.list,
                      size: 20,
                      color: !isGridView
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. FILTER CHIPS ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenMargin),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AppChip(
                    label: 'Date ▾',
                    isSelected: sortOrder == 0,
                    onTap: () => ref.read(noteSortOrderProvider.notifier).state = 0,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  AppChip(
                    label: 'Title',
                    isSelected: sortOrder == 2,
                    onTap: () => ref.read(noteSortOrderProvider.notifier).state = 2,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  AppChip(
                    label: 'Filter ▽',
                    onTap: _showFilterSheet,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // 7. ALL NOTES CARDS (WAJIB PAKAI KARTU PROPORSI LEGA)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenMargin),
            child: filteredNotesAsync.when(
              data: (notesList) {
                if (notesList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.space32),
                    child: Center(
                      child: Column(
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.notebook,
                            size: 48,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: AppDimensions.space12),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Tidak ada catatan yang cocok dengan "${_searchController.text}".'
                                : 'Belum ada catatan.\nKetuk tombol di bawah untuk membuat yang pertama.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (isGridView) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: AppDimensions.space12,
                          mainAxisSpacing: AppDimensions.space12,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: notesList.length,
                        itemBuilder: (context, index) {
                          return _buildNotePreviewCard(
                            context: context,
                            note: notesList[index],
                          );
                        },
                      );
                    },
                  );
                }

                return Column(
                  children: notesList.map((note) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                      child: _buildNotePreviewCard(
                        context: context,
                        note: note,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading notes: $err'),
            ),
          ),

          const SizedBox(height: AppDimensions.space40 * 2),
        ],
      ),
    );
  }



  Widget _buildNotePreviewCard({
    required BuildContext context,
    required NoteItem note,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteEditorScreen(noteId: note.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: AppTypography.headingSmall(isDark: isDark),
                ),
              ),
              if (note.isPinned)
                const PhosphorIcon(
                  PhosphorIconsFill.pushPin,
                  size: 14,
                  color: AppColors.syncWarning,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(
            note.snippetSummary,
            style: AppTypography.bodyMedium(isDark: isDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year} · ${note.blocks.length} blocks',
            style: AppTypography.bodySmall(isDark: isDark),
          ),
        ],
      ),
    );
  }
}
