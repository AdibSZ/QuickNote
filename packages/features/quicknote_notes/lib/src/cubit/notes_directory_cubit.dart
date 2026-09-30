import 'dart:async';
import 'package:bloc/bloc.dart';
import '../models/block_type.dart';
import '../models/note.dart';
import '../models/note_block.dart';
import '../repository/notes_repository.dart';
import 'notes_directory_state.dart';

class NotesDirectoryCubit extends Cubit<NotesDirectoryState> {
  final NotesRepository _repository;
  StreamSubscription<List<Note>>? _notesSubscription;

  NotesDirectoryCubit(this._repository) : super(const NotesDirectoryState()) {
    _notesSubscription = _repository.notesStream.listen((notes) {
      _applyNotesUpdate(notes);
    });
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }

  void _applyNotesUpdate(List<Note> notes) {
    String selCat = state.selectedCategory;
    if (selCat != 'All' && selCat != 'Pinned' && selCat != 'Favorites' && selCat != 'Trash') {
      final exists = notes.any((n) => n.category.trim().toLowerCase() == selCat.toLowerCase());
      if (!exists) selCat = 'All';
    }
    String? selTag = state.selectedTag;
    if (selTag != null) {
      final exists = notes.any((n) => n.tags.any((t) => t.trim().toLowerCase() == selTag!.toLowerCase()));
      if (!exists) selTag = null;
    }
    emit(state.copyWith(
      allNotes: notes,
      selectedCategory: selCat,
      selectedTag: selTag,
      clearSelectedTag: selTag == null,
      isLoading: false,
    ));
  }

  void loadNotes() {
    emit(state.copyWith(isLoading: true));
    final notes = _repository.getAllNotes();
    _applyNotesUpdate(notes);
  }

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category, clearSelectedTag: true));
  }

  void selectTag(String? tag) {
    if (state.selectedTag == tag) {
      emit(state.copyWith(clearSelectedTag: true));
    } else {
      emit(state.copyWith(selectedTag: tag));
    }
  }

  void selectTab(DirectoryTab tab) {
    emit(state.copyWith(activeTab: tab));
  }

  void setSortOrder(NoteSortOrder sortOrder) {
    emit(state.copyWith(sortOrder: sortOrder));
  }

  Future<void> togglePin(String id) async {
    await _repository.togglePin(id);
    loadNotes();
  }

  Future<void> toggleFavorite(String id) async {
    final note = _repository.getNoteById(id);
    if (note == null) return;
    await _repository.saveNote(note.copyWith(
      isFavorite: !note.isFavorite,
      updatedAt: DateTime.now(),
    ));
    loadNotes();
  }

  Future<void> setNoteColor(String id, String? color) async {
    final note = _repository.getNoteById(id);
    if (note == null) return;
    await _repository.saveNote(note.copyWith(
      color: color,
      updatedAt: DateTime.now(),
    ));
    loadNotes();
  }

  Future<void> toggleLock(String id) async {
    final note = _repository.getNoteById(id);
    if (note == null) return;
    await _repository.saveNote(note.copyWith(
      isLocked: !note.isLocked,
      updatedAt: DateTime.now(),
    ));
    loadNotes();
  }

  Future<void> moveToTrash(String id) async {
    final note = _repository.getNoteById(id);
    if (note == null) return;
    await _repository.saveNote(note.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    ));
    loadNotes();
  }

  Future<void> restoreFromTrash(String id) async {
    final note = _repository.getNoteById(id);
    if (note == null) return;
    await _repository.saveNote(note.copyWith(
      isDeleted: false,
      updatedAt: DateTime.now(),
    ));
    loadNotes();
  }

  Future<void> emptyTrash() async {
    final trashNotes = _repository.getAllNotes().where((n) => n.isDeleted).toList();
    for (final note in trashNotes) {
      await _repository.deleteNote(note.id);
    }
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    final note = _repository.getNoteById(id);
    if (note != null && !note.isDeleted) {
      await moveToTrash(id);
    } else {
      await _repository.deleteNote(id);
      loadNotes();
    }
  }

  Future<Note?> duplicateNote(String id) async {
    final original = _repository.getNoteById(id);
    if (original == null) return null;
    final now = DateTime.now();
    final dupBlocks = original.blocks
        .map((b) => b.copyWith(id: 'blk-${now.microsecondsSinceEpoch}-${b.id}'))
        .toList();
    final dupNote = Note(
      id: 'note-${now.millisecondsSinceEpoch}',
      title: '${original.title} (Copy)',
      preview: original.preview,
      category: original.category,
      tags: List<String>.from(original.tags),
      createdAt: now,
      updatedAt: now,
      isPinned: false,
      blocks: dupBlocks,
    );
    await _repository.saveNote(dupNote);
    loadNotes();
    return dupNote;
  }

  Future<void> clearAllNotes() async {
    await _repository.clearAllNotes();
    loadNotes();
  }

  Future<Note> createNewNote({String? title, String? category}) async {
    final now = DateTime.now();
    final newNote = Note(
      id: 'note-${now.millisecondsSinceEpoch}',
      title: title ?? 'Untitled Note',
      preview: 'Tap to start typing...',
      category: category ?? (state.selectedCategory != 'All' && state.selectedCategory != 'Pinned' ? state.selectedCategory : 'General'),
      createdAt: now,
      updatedAt: now,
      blocks: [
        NoteBlock(
          id: 'blk-title-${now.microsecondsSinceEpoch}',
          type: BlockType.title,
          content: title ?? 'Untitled Note',
          metadata: const {
            'subtitle': 'Created just now',
            'tag1': 'Draft',
            'tag2': 'Note',
          },
        ),
        NoteBlock(
          id: 'blk-para-${now.microsecondsSinceEpoch + 1}',
          type: BlockType.paragraph,
          content: '',
        ),
      ],
    );
    await _repository.saveNote(newNote);
    loadNotes();
    return newNote;
  }

  Future<Note> createChecklistNote({String? title}) async {
    final now = DateTime.now();
    final newNote = Note(
      id: 'note-${now.millisecondsSinceEpoch}',
      title: title ?? 'To-Do List',
      preview: 'Checklist task',
      category: 'Tasks',
      createdAt: now,
      updatedAt: now,
      blocks: [
        NoteBlock(
          id: 'blk-title-${now.microsecondsSinceEpoch}',
          type: BlockType.title,
          content: title ?? 'To-Do List',
          metadata: const {'subtitle': 'Task Checklist', 'tag1': 'Tasks'},
        ),
        NoteBlock(
          id: 'blk-chk-${now.microsecondsSinceEpoch + 1}',
          type: BlockType.checklist,
          content: '',
          metadata: const {'isChecked': false},
        ),
      ],
    );
    await _repository.saveNote(newNote);
    loadNotes();
    return newNote;
  }

  Future<Note> createVoiceMemoNote({String? title}) async {
    final now = DateTime.now();
    final newNote = Note(
      id: 'note-${now.millisecondsSinceEpoch}',
      title: title ?? 'Voice Memo',
      preview: 'Voice recording',
      category: 'Audio',
      createdAt: now,
      updatedAt: now,
      blocks: [
        NoteBlock(
          id: 'blk-title-${now.microsecondsSinceEpoch}',
          type: BlockType.title,
          content: title ?? 'Voice Memo',
          metadata: const {'subtitle': 'Recorded Audio', 'tag1': 'Audio'},
        ),
        NoteBlock(
          id: 'blk-audio-${now.microsecondsSinceEpoch + 1}',
          type: BlockType.audioMemo,
          content: 'Voice Note',
          metadata: const {'durationSeconds': 0},
        ),
      ],
    );
    await _repository.saveNote(newNote);
    loadNotes();
    return newNote;
  }
}
