import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import 'blocks/heading_block_widget.dart';
import 'blocks/paragraph_block_widget.dart';
import 'blocks/audio_memo_block_widget.dart';
import 'blocks/code_block_widget.dart';
import 'blocks/checklist_block_widget.dart';
import 'blocks/callout_block_widget.dart';
import 'blocks/quote_block_widget.dart';
import 'blocks/divider_block_widget.dart';
import 'blocks/image_block_widget.dart';
import 'blocks/doodle_block_widget.dart';

class BlockItemBuilder {
  static Widget build({
    required BuildContext context,
    required NoteBlock block,
    required NoteEditorState state,
    required NoteEditorCubit cubit,
  }) {
    switch (block.type) {
      case BlockType.title:
        return const SizedBox.shrink();
      case BlockType.heading2:
        return HeadingBlockWidget(
          block: block,
          isSelected: state.selectedBlockId == block.id,
          onChanged: (val) => cubit.updateBlockContent(block.id, val),
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.paragraph:
        return ParagraphBlockWidget(
          block: block,
          isSelected: state.selectedBlockId == block.id,
          onTap: () => cubit.selectBlock(block.id),
          onChanged: (val) => cubit.updateBlockContent(block.id, val),
          onDelete: () => cubit.removeBlock(block.id),
          onTransform: (newType, content, meta) => cubit.transformBlockType(
            block.id,
            newType,
            content: content,
            metadata: meta,
          ),
        );
      case BlockType.audioMemo:
        return AudioMemoBlockWidget(
          block: block,
          onTitleChanged: (val) => cubit.updateBlockContent(block.id, val),
          onTranscriptChanged: (val) => cubit.updateBlockMetadata(block.id, {'transcript': val}),
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.codeBlock:
        return CodeBlockWidget(
          block: block,
          onChanged: (val) => cubit.updateBlockContent(block.id, val),
          onLanguageChanged: (lang) => cubit.updateBlockMetadata(block.id, {'language': lang}),
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.diagram:
        return const SizedBox.shrink();
      case BlockType.checklist:
        return ChecklistBlockWidget(
          block: block,
          isSelected: state.selectedBlockId == block.id,
          onToggle: (checked) => cubit.updateBlockMetadata(block.id, {'isChecked': checked}),
          onChanged: (val) => cubit.updateBlockContent(block.id, val),
          onDelete: () => cubit.removeBlock(block.id),
          onEnterNext: () => cubit.addBlockAfter(
            block.id,
            BlockType.checklist,
            content: '',
            metadata: {'isChecked': false},
          ),
        );
      case BlockType.callout:
        return CalloutBlockWidget(
          block: block,
          isSelected: state.selectedBlockId == block.id,
          onChanged: (val) => cubit.updateBlockContent(block.id, val),
          onStyleChanged: (icon, tint) => cubit.updateBlockMetadata(
            block.id,
            {'icon': icon, 'tint': tint},
          ),
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.quote:
        return QuoteBlockWidget(
          block: block,
          isSelected: state.selectedBlockId == block.id,
          onChanged: (val) => cubit.updateBlockContent(block.id, val),
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.divider:
        return DividerBlockWidget(
          block: block,
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.image:
        return ImageBlockWidget(
          block: block,
          onCaptionChanged: (val) => cubit.updateBlockMetadata(block.id, {'caption': val}),
          onDelete: () => cubit.removeBlock(block.id),
        );
      case BlockType.doodle:
        return DoodleBlockWidget(
          block: block,
          onContentChanged: (val) => cubit.updateBlockContent(block.id, val),
          onDelete: () => cubit.removeBlock(block.id),
        );
    }
  }
}
