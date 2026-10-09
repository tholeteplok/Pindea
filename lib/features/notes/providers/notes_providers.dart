import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers/database_providers.dart';
import '../data/notes_repository.dart';
import '../domain/models/note_item.dart';

/// Provider for the active local user ID
final currentUserIdProvider = FutureProvider<String>((ref) async {
  final deviceDb = ref.watch(deviceDatabaseProvider);
  final users = await deviceDb.select(deviceDb.localUsers).get();
  if (users.isNotEmpty) {
    return users.first.userId;
  }
  final manager = ref.watch(workspaceManagerProvider);
  await manager.initializeDefaultIfEmpty();
  final refreshedUsers = await deviceDb.select(deviceDb.localUsers).get();
  return refreshedUsers.first.userId;
});

/// Provider for NotesRepository based on current active workspace
final notesRepositoryProvider = FutureProvider<NotesRepository?>((ref) async {
  final deviceDb = ref.watch(deviceDatabaseProvider);
  final workspaceDb = await ref.watch(currentWorkspaceDatabaseProvider.future);

  if (workspaceDb == null) return null;

  return NotesRepository(
    deviceDb: deviceDb,
    workspaceDb: workspaceDb,
  );
});

/// StreamProvider of all notes for the active workspace
final notesStreamProvider = StreamProvider<List<NoteItem>>((ref) async* {
  final repo = await ref.watch(notesRepositoryProvider.future);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  final userId = await ref.watch(currentUserIdProvider.future);

  if (repo == null || activeWorkspaceId == null) {
    yield [];
    return;
  }

  yield* repo.watchNotes(activeWorkspaceId, userId);
});

/// StreamProvider of pinned notes (Quick Notes)
final pinnedNotesStreamProvider = StreamProvider<List<NoteItem>>((ref) async* {
  final repo = await ref.watch(notesRepositoryProvider.future);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  final userId = await ref.watch(currentUserIdProvider.future);

  if (repo == null || activeWorkspaceId == null) {
    yield [];
    return;
  }

  yield* repo.watchPinnedNotes(activeWorkspaceId, userId);
});

/// StreamProvider of trash notes (Soft-deleted notes)
final trashNotesStreamProvider = StreamProvider<List<NoteItem>>((ref) async* {
  final repo = await ref.watch(notesRepositoryProvider.future);
  final activeWorkspaceId = ref.watch(activeWorkspaceIdProvider);
  final userId = await ref.watch(currentUserIdProvider.future);

  if (repo == null || activeWorkspaceId == null) {
    yield [];
    return;
  }

  yield* repo.watchTrashNotes(activeWorkspaceId, userId);
});

/// Search query state for real-time filtering
final noteSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected folder filter (null = all folders)
final selectedFolderFilterProvider = StateProvider<String?>((ref) => null);

/// Sort order: 0 = Terbaru, 1 = Terlama, 2 = Alfabetis
final noteSortOrderProvider = StateProvider<int>((ref) => 0);

/// Filtered and sorted notes provider based on search query, folder filter, and sort order
final filteredNotesProvider = Provider<AsyncValue<List<NoteItem>>>((ref) {
  final notesAsync = ref.watch(notesStreamProvider);
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();
  final folder = ref.watch(selectedFolderFilterProvider);
  final sortOrder = ref.watch(noteSortOrderProvider);

  return notesAsync.whenData((notes) {
    var list = notes;

    // Filter by folder if selected
    if (folder != null && folder != 'Semua') {
      list = list.where((n) => n.folderId == folder).toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      list = list.where((n) {
        final titleMatches = n.title.toLowerCase().contains(query);
        final contentMatches = n.blocks.any((b) => b.content.toLowerCase().contains(query));
        return titleMatches || contentMatches;
      }).toList();
    }

    // Apply sorting
    final sorted = List<NoteItem>.from(list);
    switch (sortOrder) {
      case 1: // Terlama
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 2: // Alfabetis (A-Z)
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 0: // Terbaru (default)
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  });
});

/// Filtered pinned notes provider based on search query
final filteredPinnedNotesProvider = Provider<AsyncValue<List<NoteItem>>>((ref) {
  final pinnedAsync = ref.watch(pinnedNotesStreamProvider);
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();

  return pinnedAsync.whenData((notes) {
    if (query.isEmpty) return notes;
    return notes.where((n) {
      final titleMatches = n.title.toLowerCase().contains(query);
      final contentMatches = n.blocks.any((b) => b.content.toLowerCase().contains(query));
      return titleMatches || contentMatches;
    }).toList();
  });
});

/// View mode preference: true for Grid view, false for List view
final noteViewModeIsGridProvider = StateProvider<bool>((ref) => false);

