import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import '../../../reminders/presentation/widgets/note_reminder_modal.dart';
import '../../../security/presentation/widgets/note_security_modal.dart';
import '../../../sharing/presentation/widgets/aesthetic_card_modal.dart';
import '../../../zen/presentation/widgets/zen_mode_modal.dart';
import '../widgets/editor_header.dart';
import '../widgets/docked_bottom_bar.dart';
import '../widgets/block_format_sheet.dart';
import '../widgets/note_color_picker_modal.dart';
import '../widgets/editor_stats_hud.dart';
import '../widgets/blocks/title_block_widget.dart';
import '../widgets/block_item_builder.dart';
import '../widgets/export_note_modal.dart';
import '../widgets/animated_block_entry.dart';

class NoteEditorScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onDelete;

  const NoteEditorScreen({
    super.key,
    required this.onBack,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteEditorCubit, NoteEditorState>(
      builder: (context, state) {
        final cubit = context.read<NoteEditorCubit>();
        final contentBlocks = state.blocks.where((b) => b.type != BlockType.title).toList();
        final dirState = context.watch<NotesDirectoryCubit>().state;
        final existingCats = dirState.availableCategories.where((c) => c != 'All' && c != 'Pinned').toSet();
        final existingTags = dirState.availableTags;

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
              if (cubit.canUndo) cubit.undo();
            },
            const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () {
              if (cubit.canUndo) cubit.undo();
            },
            const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): () {
              if (cubit.canRedo) cubit.redo();
            },
            const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): () {
              if (cubit.canRedo) cubit.redo();
            },
            const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
              if (cubit.canRedo) cubit.redo();
            },
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditorHeader(
                      onBack: onBack,
                      isSaving: state.isSaving,
                      noteTitle: state.note.title,
                      isPinned: state.note.isPinned,
                      isFavorite: state.note.isFavorite,
                      isLocked: state.note.isLocked,
                      noteColor: state.note.color,
                      onTogglePin: () => cubit.togglePin(),
                      onToggleFavorite: () => cubit.toggleFavorite(),
                      onToggleLock: () {
                        if (state.note.isLocked) {
                          NoteSecurityModal.show(
                            context,
                            noteTitle: state.note.title,
                            onAuthenticated: () => cubit.toggleLock(),
                          );
                        } else {
                          cubit.toggleLock();
                        }
                      },
                      onZenMode: () => ZenModeModal.show(context, state.note),
                      onShareAesthetic: () => AestheticCardModal.show(context, state.note),
                      onReminder: () => NoteReminderModal.show(
                        context,
                        currentReminder: state.note.reminderAt,
                        onSave: (dt) => cubit.setReminder(dt),
                      ),
                      hasReminder: state.note.reminderAt != null,
                      onPickColor: () => NoteColorPickerModal.show(
                        context,
                        currentColor: state.note.color,
                        onColorSelected: (c) => cubit.setColor(c),
                      ),
                      onDeleteNote: onDelete,
                      onExport: () => ExportNoteModal.show(context, state.note),
                      onUndo: cubit.canUndo ? () => cubit.undo() : null,
                      onRedo: cubit.canRedo ? () => cubit.redo() : null,
                      wordCount: state.note.wordCount,
                    ),
                  // Fixed Stationary Title Section (NOT reorderable, always stays on top)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TitleBlockWidget(
                      title: state.note.title,
                      category: state.note.category,
                      tags: state.note.tags,
                      existingCategories: existingCats,
                      existingTags: existingTags,
                      onTitleChanged: (val) => cubit.updateTitle(val),
                      onCategoryChanged: (cat) => cubit.updateCategory(cat),
                      onTagsChanged: (tags) => cubit.updateTags(tags),
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  // Content Blocks (Reorderable with only left handle, no right-side double lines)
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false, // REMOVE default right-side "=" lines
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 100),
                        physics: const BouncingScrollPhysics(),
                        itemCount: contentBlocks.length,
                        onReorderStart: (_) => TactileFeedback.medium(),
                        onReorderItem: (oldIndex, newIndex) {
                          TactileFeedback.heavy();
                          cubit.reorderBlocks(oldIndex, newIndex);
                        },
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, _) {
                              final animVal = Curves.easeOutCubic.transform(animation.value);
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              return Material(
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.0 + (0.02 * animVal),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                                          blurRadius: 28,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: const Color(0xFFAAC7FF).withValues(alpha: 0.45 * animVal),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        itemBuilder: (context, index) {
                          final block = contentBlocks[index];
                          return AnimatedBlockEntry(
                            key: ValueKey(block.id),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left drag handle ONLY
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                      margin: const EdgeInsets.only(top: 4, right: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkSurfaceContainerHigh.withValues(alpha: 0.8)
                                            : AppColors.lightSurfaceContainerHigh.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.drag_indicator,
                                        size: 14,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkOutlineVariant
                                            : AppColors.lightOutlineVariant,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: BlockItemBuilder.build(
                                      context: context,
                                      block: block,
                                      state: state,
                                      cubit: cubit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 72,
                right: 20,
                child: EditorStatsHud(note: state.note),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DockedBottomBar(
                  onAddBlock: () => cubit.addBlock(BlockType.paragraph, content: ''),
                  onAddHeading: () => cubit.addBlock(BlockType.heading2, content: '', metadata: {'fontSize': 20.0}),
                  onAddDivider: () => cubit.addBlock(BlockType.divider, content: ''),
                  onVoiceRecorded: (sec, path) => cubit.addBlock(
                    BlockType.audioMemo,
                    content: 'Voice Memo',
                    metadata: {
                      'durationSeconds': sec,
                      if (path != null) 'audioPath': path,
                    },
                  ),
                  onAddChecklist: () => cubit.addBlock(
                    BlockType.checklist,
                    content: '',
                    metadata: {'isChecked': false},
                  ),
                  onInsertDate: () {
                    final n = DateTime.now();
                    final m = n.month.toString().padLeft(2, '0');
                    final d = n.day.toString().padLeft(2, '0');
                    cubit.addBlock(BlockType.paragraph, content: '📅 ${n.year}/$m/$d');
                  },
                  onAddImage: (path) => cubit.addBlock(
                    BlockType.image,
                    content: path,
                    metadata: {'caption': ''},
                  ),
                  onAddDoodle: (json) => cubit.addBlock(
                    BlockType.doodle,
                    content: json,
                  ),
                  onAddCallout: () => cubit.addBlock(
                    BlockType.callout,
                    content: '',
                    metadata: {'icon': '💡'},
                  ),
                  onInsertCode: () => cubit.addBlock(
                    BlockType.codeBlock,
                    content: '// Write code here\n',
                    metadata: {'language': 'DART'},
                  ),
                  onAddQuote: () => cubit.addBlock(
                    BlockType.quote,
                    content: '',
                  ),
                  onFormatText: () => BlockFormatSheet.show(context, cubit),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }
}
