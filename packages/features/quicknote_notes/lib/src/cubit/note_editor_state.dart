import 'package:equatable/equatable.dart';
import '../models/note.dart';
import '../models/note_block.dart';

class NoteEditorState extends Equatable {
  final Note note;
  final List<NoteBlock> blocks;
  final bool isSaving;
  final String? selectedBlockId;
  final DateTime? lastSavedAt;

  const NoteEditorState({
    required this.note,
    required this.blocks,
    this.isSaving = false,
    this.selectedBlockId,
    this.lastSavedAt,
  });

  NoteEditorState copyWith({
    Note? note,
    List<NoteBlock>? blocks,
    bool? isSaving,
    String? selectedBlockId,
    DateTime? lastSavedAt,
  }) {
    return NoteEditorState(
      note: note ?? this.note,
      blocks: blocks ?? this.blocks,
      isSaving: isSaving ?? this.isSaving,
      selectedBlockId: selectedBlockId ?? this.selectedBlockId,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  List<Object?> get props => [note, blocks, isSaving, selectedBlockId, lastSavedAt];
}
