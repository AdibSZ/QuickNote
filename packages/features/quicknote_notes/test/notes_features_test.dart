import 'package:quicknote_notes/quicknote_notes.dart';
import 'package:quicknote_storage/quicknote_storage.dart';
import 'package:test/test.dart';

void main() {
  group('Note Model & Markdown Export', () {
    test('serialization with new luxury attributes', () {
      final now = DateTime.now();
      final note = Note(
        id: 'test-1',
        title: 'VisionOS Architecture',
        preview: 'Exploring frosted glass aesthetics',
        category: 'Architecture',
        tags: ['visionos', 'design'],
        color: 'ocean',
        isFavorite: true,
        isLocked: true,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
        blocks: [
          NoteBlock(id: 'b1', type: BlockType.callout, content: 'Pro tip: keep it minimal', metadata: {'icon': '💡'}),
          NoteBlock(id: 'b2', type: BlockType.quote, content: 'Simplicity is the ultimate sophistication'),
          NoteBlock(id: 'b3', type: BlockType.divider, content: ''),
        ],
      );

      final json = note.toJson();
      expect(json['color'], 'ocean');
      expect(json['isFavorite'], true);
      expect(json['isLocked'], true);

      final restored = Note.fromJson(json);
      expect(restored.id, note.id);
      expect(restored.color, 'ocean');
      expect(restored.isFavorite, true);
      expect(restored.isLocked, true);
      expect(restored.blocks.length, 3);
      expect(restored.blocks[0].type, BlockType.callout);
      expect(restored.blocks[1].type, BlockType.quote);
      expect(restored.blocks[2].type, BlockType.divider);
    });

    test('markdown export renders callout, quote and divider properly', () {
      final note = Note(
        id: 'test-md',
        title: 'Project Notes',
        preview: 'Highlight box',
        category: 'General',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        blocks: [
          NoteBlock(id: 'b1', type: BlockType.callout, content: 'Highlight box', metadata: {'icon': '🚀'}),
          NoteBlock(id: 'b2', type: BlockType.quote, content: 'Wise words'),
          NoteBlock(id: 'b3', type: BlockType.divider, content: ''),
          NoteBlock(id: 'b4', type: BlockType.checklist, content: 'Ship update', metadata: {'isChecked': true}),
        ],
      );

      final md = note.toMarkdown();
      expect(md, contains('> 🚀 **Highlight box**'));
      expect(md, contains('> *Wise words*'));
      expect(md, contains('---'));
      expect(md, contains('- [x] Ship update'));
    });
  });

  group('NotesDirectoryCubit Advanced Features', () {
    late InProcessNotesRepository repo;
    late NotesDirectoryCubit cubit;

    setUp(() async {
      repo = InProcessNotesRepository(DeltaFlushPersister(primaryMemory: InMemoryStorageDriver()));
      await repo.init();
      cubit = NotesDirectoryCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('favorite, color tint, and trash workflow', () async {
      final note = await cubit.createNewNote(title: 'Craft Note', category: 'Work');
      expect(cubit.state.allCount, 1);
      expect(cubit.state.favoritesCount, 0);

      // Toggle favorite
      await cubit.toggleFavorite(note.id);
      expect(cubit.state.favoritesCount, 1);

      // Set color tint
      await cubit.setNoteColor(note.id, 'lavender');
      final coloredNote = repo.getNoteById(note.id);
      expect(coloredNote?.color, 'lavender');

      // Move to trash
      await cubit.moveToTrash(note.id);
      expect(cubit.state.trashCount, 1);
      expect(cubit.state.allCount, 0);

      // Filter trash
      cubit.selectCategory('Trash');
      expect(cubit.state.filteredNotes.length, 1);

      // Restore from trash
      await cubit.restoreFromTrash(note.id);
      expect(cubit.state.trashCount, 0);
      expect(cubit.state.allCount, 1);
    });
  });
}
