import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class SpotlightSearchModal {
  static void show({
    required BuildContext context,
    ValueChanged<Note>? onNoteSelected,
    ValueChanged<Note>? onSelectNote,
    VoidCallback? onNewNote,
  }) {
    final noteCallback = onNoteSelected ?? onSelectNote;
    if (noteCallback == null) return;
    TactileFeedback.click();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => _SpotlightDialog(
        onSelectNote: noteCallback,
        onNewNote: onNewNote ?? () {},
      ),
    );
  }
}

class _SpotlightDialog extends StatefulWidget {
  final ValueChanged<Note> onSelectNote;
  final VoidCallback onNewNote;

  const _SpotlightDialog({
    required this.onSelectNote,
    required this.onNewNote,
  });

  @override
  State<_SpotlightDialog> createState() => _SpotlightDialogState();
}

class _SpotlightDialogState extends State<_SpotlightDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final allNotes = context.watch<NotesDirectoryCubit>().state.allNotes.where((n) => !n.isDeleted).toList();

    final filteredNotes = _query.isEmpty
        ? allNotes.take(4).toList()
        : allNotes.where((n) {
            final q = _query.toLowerCase();
            return n.title.toLowerCase().contains(q) ||
                n.preview.toLowerCase().contains(q) ||
                n.category.toLowerCase().contains(q) ||
                n.tags.any((t) => t.toLowerCase().contains(q));
          }).take(6).toList();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 580,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.96)
                : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: AppTypography.body(onSurface, size: 15),
                        decoration: InputDecoration(
                          hintText: TextRegistry.get(TextKey.searchPlaceholder),
                          hintStyle: AppTypography.body(onSurfaceVar.withValues(alpha: 0.6), size: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _query = val),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('ESC', style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (_query.isEmpty) ...[
                      _buildSectionHeader('QUICK ACTIONS', onSurfaceVar),
                      _buildActionTile(
                        icon: Icons.add_circle_outline,
                        title: 'Create New Note',
                        shortcut: 'Ctrl+N',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onNewNote();
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.star_border_rounded,
                        title: 'Filter: Favorites',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          context.read<NotesDirectoryCubit>().selectCategory('Favorites');
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.brightness_6_outlined,
                        title: 'Toggle Theme (Light / Dark)',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                    ],
                    if (filteredNotes.isNotEmpty) ...[
                      _buildSectionHeader(
                        _query.isEmpty ? 'RECENT NOTES' : 'MATCHING NOTES (${filteredNotes.length})',
                        onSurfaceVar,
                      ),
                      ...filteredNotes.map((note) => _buildNoteTile(note, isDark, onSurface, onSurfaceVar)),
                    ] else if (_query.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No notes found for "$_query"',
                            style: AppTypography.body(onSurfaceVar, size: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: AppTypography.caption(color.withValues(alpha: 0.6), size: 10, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? shortcut,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, size: 18, color: onSurfaceVar),
      title: Text(title, style: AppTypography.body(onSurface, size: 13, weight: FontWeight.w500)),
      trailing: shortcut != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(shortcut, style: AppTypography.caption(onSurfaceVar, size: 10)),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildNoteTile(Note note, bool isDark, Color onSurface, Color onSurfaceVar) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(
        note.isFavorite ? Icons.star_rounded : (note.isPinned ? Icons.push_pin : Icons.description_outlined),
        size: 18,
        color: note.isFavorite ? Colors.amber : onSurfaceVar,
      ),
      title: Text(
        note.title.isEmpty ? 'Untitled Note' : note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.body(onSurface, size: 13, weight: FontWeight.w600),
      ),
      subtitle: Text(
        note.preview.isEmpty ? 'Empty...' : note.preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption(onSurfaceVar, size: 11),
      ),
      trailing: note.category != 'General'
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                note.category,
                style: AppTypography.caption(isDark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 9),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        widget.onSelectNote(note);
      },
    );
  }
}
