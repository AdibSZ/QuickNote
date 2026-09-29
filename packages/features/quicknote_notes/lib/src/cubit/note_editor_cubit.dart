import 'package:bloc/bloc.dart';
import '../models/block_type.dart';
import '../models/note.dart';
import '../models/note_block.dart';
import '../repository/notes_repository.dart';
import 'note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  final NotesRepository _repository;

  NoteEditorCubit({
    required Note note,
    required NotesRepository repository,
  })  : _repository = repository,
        super(NoteEditorState(note: note, blocks: List.from(note.blocks)));

  void selectBlock(String? blockId) {
    emit(state.copyWith(selectedBlockId: blockId));
  }

  void updateTitle(String newTitle) {
    // Also update any title block in the list if present
    final updatedBlocks = state.blocks.map((b) {
      if (b.type == BlockType.title) {
        return b.copyWith(content: newTitle);
      }
      return b;
    }).toList();

    final updatedNote = state.note.copyWith(
      title: newTitle,
      blocks: updatedBlocks,
      updatedAt: DateTime.now(),
    );

    emit(state.copyWith(note: updatedNote, blocks: updatedBlocks));
    _autoSave();
  }

  void updateCategory(String newCategory) {
    final updatedNote = state.note.copyWith(
      category: newCategory,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(note: updatedNote));
    _autoSave();
  }

  void updateTags(List<String> newTags) {
    final updatedNote = state.note.copyWith(
      tags: newTags,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(note: updatedNote));
    _autoSave();
  }

  Future<void> togglePin() async {
    final updatedNote = state.note.copyWith(
      isPinned: !state.note.isPinned,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(note: updatedNote));
    await _repository.saveNote(updatedNote);
  }

  Future<void> toggleFavorite() async {
    final updatedNote = state.note.copyWith(
      isFavorite: !state.note.isFavorite,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(note: updatedNote));
    await _repository.saveNote(updatedNote);
  }

  Future<void> setColor(String? color) async {
    final updatedNote = state.note.copyWith(
      color: color,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(note: updatedNote));
    await _repository.saveNote(updatedNote);
  }

  Future<void> toggleLock() async {
    final updatedNote = state.note.copyWith(
      isLocked: !state.note.isLocked,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(note: updatedNote));
    await _repository.saveNote(updatedNote);
  }

  final List<List<NoteBlock>> _undoStack = [];
  final List<List<NoteBlock>> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _recordHistory() {
    _undoStack.add(List.from(state.blocks));
    if (_undoStack.length > 30) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List.from(state.blocks));
    final prev = _undoStack.removeLast();
    emit(state.copyWith(blocks: prev));
    _autoSave();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List.from(state.blocks));
    final next = _redoStack.removeLast();
    emit(state.copyWith(blocks: next));
    _autoSave();
  }

  void addBlock(BlockType type, {String content = '', Map<String, dynamic>? metadata}) {
    _recordHistory();
    final newBlock = NoteBlock(
      id: 'blk-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      content: content,
      metadata: metadata ?? {},
    );
    final updatedList = List<NoteBlock>.from(state.blocks)..add(newBlock);
    emit(state.copyWith(blocks: updatedList, selectedBlockId: newBlock.id));
    _autoSave();
  }

  void addBlockAfter(String currentBlockId, BlockType type, {String content = '', Map<String, dynamic>? metadata}) {
    _recordHistory();
    final newBlock = NoteBlock(
      id: 'blk-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      content: content,
      metadata: metadata ?? {},
    );
    final idx = state.blocks.indexWhere((b) => b.id == currentBlockId);
    final updatedList = List<NoteBlock>.from(state.blocks);
    if (idx != -1 && idx < updatedList.length) {
      updatedList.insert(idx + 1, newBlock);
    } else {
      updatedList.add(newBlock);
    }
    emit(state.copyWith(blocks: updatedList, selectedBlockId: newBlock.id));
    _autoSave();
  }

  void transformBlockType(String id, BlockType newType, {String? content, Map<String, dynamic>? metadata}) {
    _recordHistory();
    final updatedList = state.blocks.map((block) {
      if (block.id == id) {
        final defaultMeta = newType == BlockType.checklist
            ? {'isChecked': false}
            : (newType == BlockType.codeBlock
                ? {'language': 'DART'}
                : (newType == BlockType.callout
                    ? {'icon': '💡', 'tint': 'amber'}
                    : <String, dynamic>{}));
        return block.copyWith(
          type: newType,
          content: content ?? block.content,
          metadata: metadata ?? defaultMeta,
        );
      }
      return block;
    }).toList();
    emit(state.copyWith(blocks: updatedList, selectedBlockId: id));
    _autoSave();
  }

  void updateBlockContent(String id, String newContent) {
    final updatedList = state.blocks.map((block) {
      if (block.id == id) {
        return block.copyWith(content: newContent);
      }
      return block;
    }).toList();

    // If this is the title block, sync with note.title as well
    String noteTitle = state.note.title;
    final block = state.blocks.firstWhere((b) => b.id == id, orElse: () => state.blocks.first);
    if (block.type == BlockType.title) {
      noteTitle = newContent;
    }

    emit(state.copyWith(
      blocks: updatedList,
      note: state.note.copyWith(title: noteTitle),
    ));
    _autoSave();
  }

  void updateBlockType(String id, BlockType newType) {
    final updatedList = state.blocks.map((block) {
      if (block.id == id) {
        return block.copyWith(type: newType);
      }
      return block;
    }).toList();

    emit(state.copyWith(blocks: updatedList));
    _autoSave();
  }

  void updateBlockMetadata(String id, Map<String, dynamic> newMetadata) {
    final updatedList = state.blocks.map((block) {
      if (block.id == id) {
        final merged = Map<String, dynamic>.from(block.metadata)..addAll(newMetadata);
        return block.copyWith(metadata: merged);
      }
      return block;
    }).toList();

    emit(state.copyWith(blocks: updatedList));
    _autoSave();
  }

  void removeBlock(String id) {
    _recordHistory();
    final updatedList = state.blocks.where((b) => b.id != id).toList();
    emit(state.copyWith(blocks: updatedList, selectedBlockId: null));
    _autoSave();
  }

  void reorderBlocks(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.blocks.length) return;
    if (newIndex < 0 || newIndex > state.blocks.length) return;

    _recordHistory();
    final updated = List<NoteBlock>.from(state.blocks);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    emit(state.copyWith(blocks: updated));
    _autoSave();
  }

  Future<void> _autoSave() async {
    emit(state.copyWith(isSaving: true));

    final updatedNote = state.note.copyWith(
      blocks: state.blocks,
      updatedAt: DateTime.now(),
      preview: _extractPreview(state.blocks),
    );

    await _repository.saveNote(updatedNote);

    emit(state.copyWith(
      note: updatedNote,
      isSaving: false,
      lastSavedAt: DateTime.now(),
    ));
  }

  String _extractPreview(List<NoteBlock> blocks) {
    for (final b in blocks) {
      if (b.type == BlockType.paragraph && b.content.trim().isNotEmpty) {
        return b.content.trim();
      }
    }
    return state.note.preview;
  }
}
