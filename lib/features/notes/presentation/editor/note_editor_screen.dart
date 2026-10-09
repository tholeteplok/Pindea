import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/database/providers/database_providers.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_dimensions.dart';
import '../../../../core/theme/tokens/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_image_viewer.dart';
import '../../domain/models/block_item.dart';
import '../../domain/models/note_item.dart';
import '../../providers/notes_providers.dart';
import '../../services/export_import_service.dart';

/// Note Editor Screen V1.0 for Pindea
/// Strict adherence to visual rules:
/// - Header: Seamless (No card container, naked icon buttons)
/// - Editor Canvas: Seamless (No card container, content flows naturally)
/// - 6 Block Types: Text, Heading, Checklist, Bullet, Image, Link
/// - Drag Handle & Floating Bottom Dock Toolbar
class NoteEditorScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteEditorScreen({
    super.key,
    required this.noteId,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  final Map<String, TextEditingController> _blockControllers = {};
  final Map<String, FocusNode> _blockFocusNodes = {};
  Timer? _titleDebounceTimer;
  Timer? _blockDebounceTimer;
  NoteItem? _note;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _loadNote();
  }

  TextEditingController _getControllerForBlock(BlockItem block) {
    if (!_blockControllers.containsKey(block.id)) {
      _blockControllers[block.id] = TextEditingController(text: block.content);
    } else {
      final node = _blockFocusNodes[block.id];
      if ((node == null || !node.hasFocus) && _blockControllers[block.id]!.text != block.content) {
        _blockControllers[block.id]!.text = block.content;
      }
    }
    return _blockControllers[block.id]!;
  }

  FocusNode _getFocusNodeForBlock(BlockItem block) {
    if (!_blockFocusNodes.containsKey(block.id)) {
      _blockFocusNodes[block.id] = FocusNode();
    }
    return _blockFocusNodes[block.id]!;
  }

  @override
  void dispose() {
    _titleDebounceTimer?.cancel();
    _blockDebounceTimer?.cancel();
    _titleController.dispose();
    for (final c in _blockControllers.values) {
      c.dispose();
    }
    for (final f in _blockFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _loadNote() async {
    final repo = await ref.read(notesRepositoryProvider.future);
    final userId = await ref.read(currentUserIdProvider.future);
    final activeWsId = ref.read(activeWorkspaceIdProvider) ?? 'default';

    if (repo != null) {
      final note = await repo.getNoteById(activeWsId, userId, widget.noteId);
      if (note != null && mounted) {
        setState(() {
          _note = note;
          _titleController.text = note.title;
          _isLoading = false;
        });
      }
    }
  }

  void _onTitleChanged(String newTitle) {
    _titleDebounceTimer?.cancel();
    _titleDebounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final repo = await ref.read(notesRepositoryProvider.future);
      if (repo != null && _note != null) {
        setState(() => _isSaving = true);
        await repo.updateNoteTitle(_note!.workspaceId, _note!.id, newTitle);
        if (mounted) setState(() => _isSaving = false);
      }
    });
  }

  Future<void> _addBlock(BlockType type) async {
    final repo = await ref.read(notesRepositoryProvider.future);
    if (repo != null && _note != null) {
      final initialContent = type == BlockType.heading ? 'Judul Bagian' : '';
      final newBlock = await repo.addBlock(
        _note!.workspaceId,
        _note!.id,
        type,
        content: initialContent,
      );
      _blockControllers[newBlock.id] = TextEditingController(text: initialContent);
      final newFocus = FocusNode();
      _blockFocusNodes[newBlock.id] = newFocus;
      setState(() {
        _note = _note!.copyWith(blocks: [..._note!.blocks, newBlock]);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        newFocus.requestFocus();
      });
    }
  }

  Future<void> _pickAndAddImage(BuildContext context, bool isDark) async {
    final picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);

    AppBottomSheet.show(
      context: context,
      title: 'Pilih Sumber Gambar',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.secondary(
            label: 'Pilih dari Galeri / Berkas Lokal',
            icon: PhosphorIcons.image(),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  await _saveAndInsertImageBlock(picked.path);
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Gagal memilih gambar: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: AppDimensions.space12),
          AppButton.secondary(
            label: 'Ambil Foto dari Kamera',
            icon: PhosphorIcons.camera(),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final XFile? picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  await _saveAndInsertImageBlock(picked.path);
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Kamera tidak tersedia atau izin ditolak: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: AppDimensions.space16),
        ],
      ),
    );
  }

  Future<void> _saveAndInsertImageBlock(String originalPath) async {
    try {
      final repo = await ref.read(notesRepositoryProvider.future);
      if (repo == null || _note == null) return;

      final appDocDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDocDir.path, 'note_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(originalPath)}';
      final savedImage = await File(originalPath).copy(p.join(imagesDir.path, fileName));

      final newBlock = await repo.addBlock(
        _note!.workspaceId,
        _note!.id,
        BlockType.image,
        url: savedImage.path,
        content: '',
      );

      _blockControllers[newBlock.id] = TextEditingController(text: '');
      _blockFocusNodes[newBlock.id] = FocusNode();

      if (mounted) {
        setState(() {
          _note = _note!.copyWith(blocks: [..._note!.blocks, newBlock]);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan gambar: $e')),
        );
      }
    }
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      height: 140,
      width: double.infinity,
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.image,
              size: 32,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: AppDimensions.space6),
            Text(
              'Gambar tidak ditemukan',
              style: AppTypography.bodySmall(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _onBlockContentChanged(BlockItem block, String newContent) {
    final repo = ref.read(notesRepositoryProvider).value;
    if (repo != null && _note != null) {
      final updated = block.copyWith(content: newContent);
      final idx = _note!.blocks.indexWhere((b) => b.id == block.id);
      if (idx != -1) {
        final list = List<BlockItem>.from(_note!.blocks);
        list[idx] = updated;
        _note = _note!.copyWith(blocks: list);
      }

      _blockDebounceTimer?.cancel();
      _blockDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
        if (mounted) setState(() => _isSaving = true);
        await repo.updateBlock(_note!.workspaceId, updated);
        if (mounted) setState(() => _isSaving = false);
      });
    }
  }

  Future<void> _toggleChecklist(BlockItem block) async {
    final repo = await ref.read(notesRepositoryProvider.future);
    if (repo != null && _note != null) {
      final updated = block.copyWith(isDone: !block.isDone);
      setState(() {
        final idx = _note!.blocks.indexWhere((b) => b.id == block.id);
        if (idx != -1) {
          final list = List<BlockItem>.from(_note!.blocks);
          list[idx] = updated;
          _note = _note!.copyWith(blocks: list);
        }
      });
      await repo.updateBlock(_note!.workspaceId, updated);
    }
  }

  Future<void> _deleteBlock(BlockItem block) async {
    final repo = await ref.read(notesRepositoryProvider.future);
    if (repo != null && _note != null) {
      _blockControllers[block.id]?.dispose();
      _blockControllers.remove(block.id);
      _blockFocusNodes[block.id]?.dispose();
      _blockFocusNodes.remove(block.id);
      setState(() {
        _note = _note!.copyWith(
          blocks: _note!.blocks.where((b) => b.id != block.id).toList(),
        );
      });
      await repo.deleteBlock(_note!.workspaceId, block.id);
    }
  }

  void _showMoreMenu() {
    if (_note == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppBottomSheet.show(
      context: context,
      title: 'Opsi Catatan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info summary
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Total Blok', style: AppTypography.monoLabel(isDark: isDark)),
                    const SizedBox(height: AppDimensions.space4),
                    Text('${_note!.blocks.length}', style: AppTypography.headingSmall(isDark: isDark)),
                  ],
                ),
                Container(width: 1, height: 28, color: AppColors.border(isDark: isDark)),
                Column(
                  children: [
                    Text('Estimasi Kata', style: AppTypography.monoLabel(isDark: isDark)),
                    const SizedBox(height: AppDimensions.space4),
                    Text('${_calculateWordCount()}', style: AppTypography.headingSmall(isDark: isDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 1. Duplikasi Catatan
          AppButton.secondary(
            label: 'Duplikasi Catatan',
            icon: PhosphorIcons.copy(),
            onPressed: () async {
              Navigator.of(context).pop();
              final repo = await ref.read(notesRepositoryProvider.future);
              final userId = await ref.read(currentUserIdProvider.future);
              if (repo != null && _note != null) {
                final duplicated = await repo.createNote(
                  workspaceId: _note!.workspaceId,
                  userId: userId,
                  title: '${_note!.title} (Salinan)',
                );
                for (final b in _note!.blocks) {
                  await repo.addBlock(
                    _note!.workspaceId,
                    duplicated.id,
                    b.type,
                    content: b.content,
                    url: b.url,
                    isDone: b.isDone,
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan berhasil diduplikasi')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: AppDimensions.space12),

          // 2. Ekspor ke Markdown
          AppButton.secondary(
            label: 'Ekspor ke Markdown (.md)',
            icon: PhosphorIcons.markdownLogo(),
            onPressed: () {
              Navigator.of(context).pop();
              final mdString = ExportImportService.exportNoteToMarkdown(_note!);
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
                        color: AppColors.surface(isDark: isDark),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        border: Border.all(color: AppColors.border(isDark: isDark)),
                      ),
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        child: Text(mdString, style: AppTypography.code(isDark: isDark)),
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
          const SizedBox(height: AppDimensions.space12),

          // 3. Pindahkan ke Kotak Sampah
          AppButton.destructive(
            label: 'Pindahkan ke Kotak Sampah',
            icon: PhosphorIcons.trash(),
            onPressed: () async {
              Navigator.of(context).pop();
              final confirmed = await AppDialog.confirm(
                context: context,
                title: 'Hapus Catatan',
                message: 'Apakah Anda yakin ingin memindahkan "${_note!.title}" ke kotak sampah?',
                confirmLabel: 'Pindahkan ke Sampah',
                isDestructive: true,
              );
              if (confirmed == true && mounted) {
                final repo = await ref.read(notesRepositoryProvider.future);
                if (repo != null && _note != null) {
                  await repo.deleteNote(_note!.workspaceId, _note!.id);
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan dipindahkan ke kotak sampah')),
                    );
                  }
                }
              }
            },
          ),
          const SizedBox(height: AppDimensions.space16),
        ],
      ),
    );
  }

  int _calculateWordCount() {
    if (_note == null) return 0;
    int count = _note!.title.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    for (final b in _note!.blocks) {
      count += b.content.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    }
    return count;
  }

  Future<void> _togglePin() async {
    final repo = await ref.read(notesRepositoryProvider.future);
    final userId = await ref.read(currentUserIdProvider.future);
    if (repo != null && _note != null) {
      final newPinned = !_note!.isPinned;
      setState(() {
        _note = _note!.copyWith(isPinned: newPinned);
      });
      await repo.togglePin(userId, _note!.id, newPinned, colorCode: _note!.colorCode ?? 'yellow');
    }
  }

  void _showColorPicker() {
    AppBottomSheet.show(
      context: context,
      title: 'Pilih Warna Quick Note',
      child: Wrap(
        spacing: AppDimensions.space12,
        runSpacing: AppDimensions.space12,
        children: QuickNoteColor.values.map((c) {
          final color = c.getColor(isDark: Theme.of(context).brightness == Brightness.dark);
          final isSelected = _note?.colorCode == c.name;
          return GestureDetector(
            onTap: () async {
              final repo = await ref.read(notesRepositoryProvider.future);
              final userId = await ref.read(currentUserIdProvider.future);
              if (repo != null && _note != null) {
                setState(() => _note = _note!.copyWith(colorCode: c.name));
                await repo.setNoteColor(userId, _note!.id, c.name);
              }
              if (mounted) Navigator.of(context).pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : AppColors.lightOutline,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: isSelected ? const Icon(Icons.check, size: 18) : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      body: Stack(
        children: [
          // Content ScrollView
          ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenMargin,
              vertical: AppDimensions.space8,
            ),
            children: [
              // 1. TOP HEADER: SEAMLESS (NO CARD CONTAINER, NAKED ICONS)
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: PhosphorIcon(PhosphorIconsBold.arrowLeft, size: 22),
                    splashRadius: 22,
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Text(
                    'Personal',
                    style: AppTypography.bodySmall(isDark: isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Pin toggle icon
                  IconButton(
                    onPressed: _togglePin,
                    icon: PhosphorIcon(
                      _note?.isPinned == true ? PhosphorIconsFill.pushPin : PhosphorIconsRegular.pushPin,
                      size: 20,
                      color: _note?.isPinned == true ? AppColors.syncWarning : null,
                    ),
                    tooltip: 'Pin Quick Note',
                    splashRadius: 22,
                  ),
                  // Color swatch button
                  IconButton(
                    onPressed: _showColorPicker,
                    icon: PhosphorIcon(PhosphorIconsRegular.palette, size: 20),
                    tooltip: 'Warna Quick Note',
                    splashRadius: 22,
                  ),
                  // More menu
                  IconButton(
                    onPressed: _showMoreMenu,
                    icon: PhosphorIcon(PhosphorIconsRegular.dotsThreeVertical, size: 20),
                    tooltip: 'Opsi Catatan',
                    splashRadius: 22,
                  ),
                ],
              ),

              // 2. SUB-HEADER META (Save status indicator)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space4,
                ),
                child: Row(
                  children: [
                    Text(
                      _isSaving ? '● Menyimpan...' : '● Tersimpan',
                      style: AppTypography.monoLabel(
                        isDark: isDark,
                        weight: FontWeight.w500,
                      ).copyWith(
                        color: _isSaving ? AppColors.syncSyncing : AppColors.syncConnected,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),
              const SizedBox(height: AppDimensions.space8),

              // 3. NOTE TITLE: SEAMLESS DIRECT ON CANVAS (NO CARD WRAPPER)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
                child: TextField(
                  controller: _titleController,
                  onChanged: _onTitleChanged,
                  style: AppTypography.headingLarge(isDark: isDark),
                  decoration: const InputDecoration(
                    hintText: 'Judul Catatan...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space16),

              // 4. NOTE CONTENT: SEAMLESS DIRECT ON CANVAS (ZERO CARD CONTAINER)
              if (_note != null)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _note!.blocks.length,
                  onReorder: (oldIndex, newIndex) {
                    // Reorder handle logic
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final block = _note!.blocks.removeAt(oldIndex);
                      _note!.blocks.insert(newIndex, block);
                    });
                  },
                  itemBuilder: (context, index) {
                    final block = _note!.blocks[index];
                    return _buildBlockWidget(block, ValueKey(block.id));
                  },
                ),

              // Extra padding for bottom dock toolbar
              const SizedBox(height: 100),
            ],
          ),

          // 5. FLOATING BOTTOM DOCK TOOLBAR
          Positioned(
            left: AppDimensions.screenMargin,
            right: AppDimensions.screenMargin,
            bottom: AppDimensions.space16,
            child: _buildBottomDockToolbar(isDark: isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockWidget(BlockItem block, Key key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _getControllerForBlock(block);
    final focusNode = _getFocusNodeForBlock(block);

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtle drag handle icon
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 6),
            child: PhosphorIcon(
              PhosphorIconsRegular.dotsSixVertical,
              size: 14,
              color: isDark ? AppColors.darkTextMuted.withAlpha(100) : AppColors.lightTextMuted.withAlpha(100),
            ),
          ),

          // Block Content by Type
          Expanded(
            child: switch (block.type) {
              BlockType.heading => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (val) => _onBlockContentChanged(block, val),
                  style: AppTypography.headingMedium(isDark: isDark),
                  decoration: const InputDecoration(
                    hintText: 'Subjudul bagian...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              BlockType.checklist => Row(
                  children: [
                    IconButton(
                      onPressed: () => _toggleChecklist(block),
                      icon: PhosphorIcon(
                        block.isDone ? PhosphorIconsFill.checkSquare : PhosphorIconsRegular.square,
                        size: 20,
                        color: block.isDone ? AppColors.syncConnected : null,
                      ),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                    const SizedBox(width: AppDimensions.space6),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) => _onBlockContentChanged(block, val),
                        style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                          decoration: block.isDone ? TextDecoration.lineThrough : null,
                          color: block.isDone ? AppColors.lightTextMuted : null,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Item checklist...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              BlockType.bullet => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8, right: 6),
                      child: Text('•', style: TextStyle(fontSize: 16)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (val) => _onBlockContentChanged(block, val),
                        style: AppTypography.bodyMedium(isDark: isDark),
                        decoration: const InputDecoration(
                          hintText: 'Poin daftar...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              BlockType.link => Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const PhosphorIcon(PhosphorIconsRegular.link, size: 20, color: Color(0xFF1976D2)),
                      const SizedBox(width: AppDimensions.space8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.content.isNotEmpty ? block.content : 'Tautan Web',
                              style: AppTypography.headingSmall(isDark: isDark),
                            ),
                            if (block.url != null)
                              Text(
                                block.url!,
                                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                                  color: const Color(0xFF1976D2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              BlockType.image => Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color: AppColors.border(isDark: isDark),
                      width: AppDimensions.borderWidthThin,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (block.url != null && block.url!.isNotEmpty && File(block.url!).existsSync())
                      ? InkWell(
                          onTap: () => AppImageViewer.open(
                            context,
                            imagePath: block.url!,
                            title: block.content.isNotEmpty ? block.content : null,
                          ),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Image.file(
                                File(block.url!),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isDark),
                              ),
                              Positioned(
                                bottom: AppDimensions.space8,
                                right: AppDimensions.space8,
                                child: Container(
                                  padding: const EdgeInsets.all(AppDimensions.space6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                                  ),
                                  child: const PhosphorIcon(
                                    PhosphorIconsRegular.arrowsOutSimple,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildImagePlaceholder(isDark),
                ),
              BlockType.text => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (val) => _onBlockContentChanged(block, val),
                  style: AppTypography.bodyMedium(isDark: isDark),
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Mulai mengetik catatan...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
            },
          ),

          // Delete block button
          IconButton(
            onPressed: () => _deleteBlock(block),
            icon: PhosphorIcon(PhosphorIconsRegular.x, size: 14),
            splashRadius: 16,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            color: AppColors.lightTextMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDockToolbar({required bool isDark}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dockButton('T', () => _addBlock(BlockType.text), isDark),
          _dockButton('H', () => _addBlock(BlockType.heading), isDark),
          _dockIcon(PhosphorIconsRegular.checkSquare, () => _addBlock(BlockType.checklist), isDark),
          _dockIcon(PhosphorIconsRegular.listBullets, () => _addBlock(BlockType.bullet), isDark),
          _dockIcon(PhosphorIconsRegular.image, () => _pickAndAddImage(context, isDark), isDark),
          _dockIcon(PhosphorIconsRegular.link, () => _addBlock(BlockType.link), isDark),
          Container(width: 1, height: 20, color: Colors.white24),
          _dockIcon(PhosphorIconsRegular.arrowCounterClockwise, () {}, isDark),
          _dockIcon(PhosphorIconsRegular.arrowClockwise, () {}, isDark),
        ],
      ),
    );
  }

  Widget _dockButton(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space8),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _dockIcon(PhosphorIconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space8),
        child: PhosphorIcon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
