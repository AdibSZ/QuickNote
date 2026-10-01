import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknote/core/localization/locale_cubit.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import 'package:quicknote_storage/quicknote_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit & TextRegistry Tests', () {
    test('TextRegistry switches between English and Persian correctly', () {
      TextRegistry.setLocale('en');
      expect(TextRegistry.currentLocale, 'en');
      expect(TextRegistry.get(TextKey.appName), 'QuickNote');
      expect(TextRegistry.get(TextKey.addBlock), 'Add Text');
      expect(TextRegistry.get(TextKey.typeTextHere), 'Type text here...');

      TextRegistry.setLocale('fa');
      expect(TextRegistry.currentLocale, 'fa');
      expect(TextRegistry.get(TextKey.appName), 'کوییک نوت');
      expect(TextRegistry.get(TextKey.addBlock), 'افزودن متن');
      expect(TextRegistry.get(TextKey.typeTextHere), 'متن را اینجا بنویسید...');

      // Switch back
      TextRegistry.setLocale('en');
      expect(TextRegistry.currentLocale, 'en');
      expect(TextRegistry.get(TextKey.appName), 'QuickNote');
    });

    test('LocaleCubit setLocale updates state and TextRegistry', () async {
      final cubit = LocaleCubit();
      await cubit.setLocale('fa');
      expect(cubit.state, const Locale('fa'));
      expect(TextRegistry.currentLocale, 'fa');
      expect(TextRegistry.get(TextKey.newNoteButton), 'یادداشت جدید');

      await cubit.setLocale('en');
      expect(cubit.state, const Locale('en'));
      expect(TextRegistry.currentLocale, 'en');
      expect(TextRegistry.get(TextKey.newNoteButton), 'New Note');
    });
  });

  group('NoteEditorCubit addBlock & No Duplicate Ghost Blocks', () {
    test('addBlock reuses existing empty paragraph block if already at end', () async {
      final persister = DeltaFlushPersister(primaryMemory: InMemoryStorageDriver());
      final repo = InProcessNotesRepository(persister);
      await repo.init();

      final note = Note(
        id: 'note-1',
        title: 'Test Note',
        preview: '',
        category: 'General',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        blocks: [
          const NoteBlock(id: 'blk-title', type: BlockType.title, content: 'Test Note'),
          const NoteBlock(id: 'blk-p1', type: BlockType.paragraph, content: ''),
        ],
      );

      final cubit = NoteEditorCubit(note: note, repository: repo);
      expect(cubit.state.blocks.length, 2);

      // Adding another empty paragraph block must not append a duplicate ghost block
      cubit.addBlock(BlockType.paragraph, content: '');
      expect(cubit.state.blocks.length, 2);
      expect(cubit.state.selectedBlockId, 'blk-p1');

      // But if the paragraph has text, adding a block does append a new one
      cubit.updateBlockContent('blk-p1', 'Hello world');
      cubit.addBlock(BlockType.paragraph, content: '');
      expect(cubit.state.blocks.length, 3);
    });

    test('addBlock adds new block types like heading2, divider, diagram directly', () async {
      final persister = DeltaFlushPersister(primaryMemory: InMemoryStorageDriver());
      final repo = InProcessNotesRepository(persister);
      await repo.init();

      final note = Note(
        id: 'note-2',
        title: 'Test 2',
        preview: '',
        category: 'General',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        blocks: [
          const NoteBlock(id: 'blk-title', type: BlockType.title, content: 'Test 2'),
        ],
      );

      final cubit = NoteEditorCubit(note: note, repository: repo);

      cubit.addBlock(BlockType.heading2, content: 'Section Header');
      expect(cubit.state.blocks.last.type, BlockType.heading2);

      cubit.addBlock(BlockType.divider);
      expect(cubit.state.blocks.last.type, BlockType.divider);

      cubit.addBlock(BlockType.checklist, content: 'Buy milk');
      expect(cubit.state.blocks.last.type, BlockType.checklist);
    });
  });
}
