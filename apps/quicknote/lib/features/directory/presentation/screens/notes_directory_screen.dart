import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../settings/presentation/settings_modal.dart';
import '../widgets/directory_header.dart';
import '../widgets/search_spotlight_bar.dart';
import '../widgets/segmented_tab_control.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/tags_view.dart';
import '../widgets/note_card_widget.dart';
import '../widgets/sort_options_modal.dart';
import '../widgets/spotlight_search_modal.dart';

class NotesDirectoryScreen extends StatelessWidget {
  final ValueChanged<Note> onNoteSelected;
  final VoidCallback onNewNote;

  const NotesDirectoryScreen({
    super.key,
    required this.onNoteSelected,
    required this.onNewNote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            SpotlightSearchModal.show(context: context, onNoteSelected: onNoteSelected, onNewNote: onNewNote),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            SpotlightSearchModal.show(context: context, onNoteSelected: onNoteSelected, onNewNote: onNewNote),
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DirectoryHeader(
                onNewNotePressed: onNewNote,
                onSettingsPressed: () => SettingsModal.show(context),
                onSortPressed: () => SortOptionsModal.show(context),
              ),
            Expanded(
              child: BlocBuilder<NotesDirectoryCubit, NotesDirectoryState>(
                builder: (context, state) {
                  final notes = state.filteredNotes;
                  final isAll = state.selectedCategory == 'All' && state.searchQuery.isEmpty;
                  final pinned = isAll ? notes.where((n) => n.isPinned).toList() : <Note>[];
                  final others = isAll ? notes.where((n) => !n.isPinned).toList() : notes;
                  final hasPinnedAndOthers = isAll && pinned.isNotEmpty && others.isNotEmpty;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final int cols;
                      final double ratio;
                      if (width >= 800) {
                        cols = 4;
                        ratio = 1.3;
                      } else if (width >= 540) {
                        cols = 3;
                        ratio = 1.25;
                      } else if (width >= 310) {
                        cols = 2;
                        ratio = 1.2;
                      } else {
                        cols = 1;
                        ratio = 2.6;
                      }

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            'Notes',
                                            style: AppTypography.display(onSurface, size: 28, weight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.darkSurfaceContainerHigh
                                                  : AppColors.lightSurfaceContainerHigh,
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                            child: Text(
                                              TextRegistry.get(
                                                TextKey.notesCount,
                                                params: {'count': '${state.allNotes.length}'},
                                              ),
                                              style: AppTypography.caption(onSurfaceVar, size: 11, weight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SegmentedTabControl(
                                    activeTab: state.activeTab,
                                    onTabChanged: (tab) => context.read<NotesDirectoryCubit>().selectTab(tab),
                                  ),
                                  const SizedBox(height: 14),
                                  SearchSpotlightBar(
                                    initialValue: state.searchQuery,
                                    onChanged: (q) => context.read<NotesDirectoryCubit>().updateSearch(q),
                                    onTapSpotlight: () =>
                                        SpotlightSearchModal.show(context: context, onNoteSelected: onNoteSelected, onNewNote: onNewNote),
                                  ),
                                  const SizedBox(height: 6),
                                  if (state.activeTab == DirectoryTab.all)
                                    CategoryFilterChips(
                                      selectedCategory: state.selectedCategory,
                                      categories: state.availableCategories,
                                      onSelected: (cat) => context.read<NotesDirectoryCubit>().selectCategory(cat),
                                    )
                                  else
                                    const TagsView(),
                                ],
                              ),
                            ),
                          ),
                          if (notes.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        state.searchQuery.isNotEmpty
                                            ? Icons.search_off_outlined
                                            : Icons.note_alt_outlined,
                                        size: 48,
                                        color: onSurfaceVar.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        state.searchQuery.isNotEmpty
                                            ? 'No Results Found'
                                            : TextRegistry.get(TextKey.emptyNotesTitle),
                                        style: AppTypography.title(onSurface, size: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.searchQuery.isNotEmpty
                                            ? 'No notes match "${state.searchQuery}"'
                                            : TextRegistry.get(TextKey.emptyNotesSubtitle),
                                        style: AppTypography.body(onSurfaceVar, size: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      if (state.searchQuery.isNotEmpty)
                                        OutlinedButton.icon(
                                          onPressed: () => context.read<NotesDirectoryCubit>().updateSearch(''),
                                          icon: const Icon(Icons.clear, size: 16),
                                          label: const Text('Clear Search'),
                                        )
                                      else
                                        ElevatedButton.icon(
                                          onPressed: onNewNote,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimary,
                                            foregroundColor: isDark ? AppColors.darkOnPrimaryContainer : Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          icon: const Icon(Icons.add, size: 16),
                                          label: Text(TextRegistry.get(TextKey.newNoteButton)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (hasPinnedAndOthers) ...[
                            _buildSectionHeader('PINNED', Icons.push_pin, primary),
                            _buildNoteGrid(pinned, cols, ratio, context, bottom: 12),
                            _buildSectionHeader('NOTES', Icons.notes, onSurfaceVar.withValues(alpha: 0.7)),
                            _buildNoteGrid(others, cols, ratio, context, bottom: 40),
                          ] else
                            _buildNoteGrid(notes, cols, ratio, context, bottom: 40),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTypography.caption(color, size: 10, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteGrid(
    List<Note> list,
    int cols,
    double ratio,
    BuildContext context, {
    double bottom = 16,
  }) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottom),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: ratio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = list[index];
            return NoteCardWidget(
              note: note,
              onTap: () => onNoteSelected(note),
              onTogglePin: () => context.read<NotesDirectoryCubit>().togglePin(note.id),
              onToggleFavorite: () => context.read<NotesDirectoryCubit>().toggleFavorite(note.id),
              onColorSelected: (c) => context.read<NotesDirectoryCubit>().setNoteColor(note.id, c),
              onDelete: () => context.read<NotesDirectoryCubit>().deleteNote(note.id),
              onDuplicate: () => context.read<NotesDirectoryCubit>().duplicateNote(note.id),
              onToggleLock: () => context.read<NotesDirectoryCubit>().toggleLock(note.id),
              onSetReminder: (dt) => context.read<NotesDirectoryCubit>().setNoteReminder(note.id, dt),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }
}
