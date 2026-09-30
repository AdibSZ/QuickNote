import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/glass_card.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import '../../../editor/presentation/widgets/note_color_picker_modal.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback? onToggleFavorite;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;
  final ValueChanged<String?>? onColorSelected;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    this.onToggleFavorite,
    required this.onDelete,
    this.onDuplicate,
    this.onColorSelected,
  });

  Color _colorForCategory(String cat, bool isDark) {
    final c = cat.toLowerCase();
    if (c == 'work' || c == 'business') return const Color(0xFF0A84FF);
    if (c.contains('strategy') || c == 'ideas') return const Color(0xFFFF9F0A);
    if (c == 'personal' || c == 'life') return const Color(0xFFFF375F);
    if (c == 'code' || c == 'tech' || c == 'swiftui') return const Color(0xFF30D158);
    if (c == 'architecture' || c == 'design') return const Color(0xFFBF5AF2);
    return isDark ? const Color(0xFFAAC7FF) : const Color(0xFF005AC1);
  }

  String _formatTime(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return d.inDays == 1 ? 'Yesterday' : '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final hasCode = note.blocks.any((b) => b.type == BlockType.codeBlock);
    final hasAudio = note.blocks.any((b) => b.type == BlockType.audioMemo);
    final hasChecklist = note.blocks.any((b) => b.type == BlockType.checklist);

    final showCategory = note.category.isNotEmpty && note.category != 'General';
    final catColor = _colorForCategory(note.category, isDark);

    final noteAccent = note.color != null
        ? NoteColorPickerModal.getAccentColor(note.color, isDark)
        : null;

    final card = GlassCard(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(16),
      borderColor: noteAccent?.withValues(alpha: isDark ? 0.45 : 0.35),
      customBackground: noteAccent?.withValues(alpha: isDark ? 0.08 : 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (note.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.push_pin, size: 14, color: primary),
                          ),
                        if (note.isFavorite)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFCC00)),
                          ),
                        if (note.isLocked)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.lock_outline, size: 13, color: onSurfaceVar),
                          ),
                        if (showCategory)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: isDark ? 0.18 : 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: catColor.withValues(alpha: isDark ? 0.4 : 0.25),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              note.category,
                              style: AppTypography.caption(catColor, size: 10, weight: FontWeight.w600),
                            ),
                          )
                        else
                          Icon(Icons.description_outlined, size: 14, color: outline),
                      ],
                    ),
                    Text(
                      _formatTime(note.updatedAt),
                      style: AppTypography.caption(onSurfaceVar, size: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.title.isEmpty ? 'Untitled Note' : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: getTextDirection(note.title, defaultIfEmpty: true),
                  textAlign: getTextAlign(note.title, defaultIfEmpty: true),
                  style: AppTypography.title(onSurface, size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    note.isLocked
                        ? '🔒 Private Note'
                        : (note.preview.isEmpty ? 'Empty note...' : note.preview),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textDirection: getTextDirection(note.preview, defaultIfEmpty: true),
                    textAlign: getTextAlign(note.preview, defaultIfEmpty: true),
                    style: AppTypography.body(
                      note.isLocked ? onSurfaceVar.withValues(alpha: 0.5) : onSurfaceVar.withValues(alpha: 0.8),
                      size: 12,
                      fontStyle: note.isLocked ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (note.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.tag, size: 11, color: primary),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      note.tags.map((t) => '#$t').join(' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(primary, size: 10, weight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasCode) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.code, size: 13)),
                    if (hasAudio) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.mic, size: 13)),
                    if (hasChecklist) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check_box_outlined, size: 13)),
                    if (!hasCode && !hasAudio && !hasChecklist) Icon(Icons.notes, size: 13, color: outline),
                  ],
                ),
                _buildMetaStats(isDark, outline),
              ],
            ),
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss-${note.id}'),
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 18),
        child: Icon(note.isFavorite ? Icons.star_border_rounded : Icons.star_rounded, color: const Color(0xFFFFCC00), size: 22),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
      ),
      confirmDismiss: (dir) async {
        TactileFeedback.selection();
        if (dir == DismissDirection.startToEnd) {
          onToggleFavorite?.call();
          return false;
        } else {
          onDelete();
          return true;
        }
      },
      child: card,
    );
  }

  Widget _buildMetaStats(bool isDark, Color outline) {
    final checklist = note.blocks.where((b) => b.type == BlockType.checklist).toList();
    if (checklist.isNotEmpty) {
      final done = checklist.where((b) => b.metadata['isChecked'] == true).length;
      final isAllDone = done == checklist.length;
      final doneColor = isDark ? const Color(0xFF30D158) : const Color(0xFF1E8E3E);
      return Text('$done/${checklist.length} done',
          style: AppTypography.caption(isAllDone ? doneColor : outline, size: 10, weight: isAllDone ? FontWeight.w600 : FontWeight.w500));
    }
    final words = note.wordCount;
    return Text(
      words > 0 ? '$words ${words == 1 ? "word" : "words"}' : '${note.blocks.length} ${note.blocks.length == 1 ? "block" : "blocks"}',
      style: AppTypography.caption(outline, size: 10),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tile(ctx, note.isPinned ? Icons.push_pin_outlined : Icons.push_pin, note.isPinned ? 'Unpin' : 'Pin to Top', onTogglePin),
              if (onToggleFavorite != null)
                _tile(ctx, note.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
                    note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites', onToggleFavorite!,
                    color: const Color(0xFFFFCC00)),
              if (onColorSelected != null)
                _tile(ctx, Icons.palette_outlined, 'Note Tint Theme',
                    () => NoteColorPickerModal.show(context, currentColor: note.color, onColorSelected: onColorSelected!)),
              if (onDuplicate != null)
                _tile(ctx, Icons.copy_outlined, 'Duplicate Note', onDuplicate!),
              _tile(ctx, Icons.delete_outline, 'Move to Trash', onDelete, color: Colors.redAccent),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
    );
  }
}
