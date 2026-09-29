import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/glass_card.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
    this.onDuplicate,
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
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.month}/${dt.day}';
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

    return GlassCard(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(16),
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
                    note.preview.isEmpty ? 'Empty note...' : note.preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textDirection: getTextDirection(note.preview, defaultIfEmpty: true),
                    textAlign: getTextAlign(note.preview, defaultIfEmpty: true),
                    style: AppTypography.body(onSurfaceVar.withValues(alpha: 0.8), size: 12),
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
                    if (hasCode) ...[
                      Icon(Icons.code, size: 13, color: outline),
                      const SizedBox(width: 4),
                    ],
                    if (hasAudio) ...[
                      Icon(Icons.mic, size: 13, color: outline),
                      const SizedBox(width: 4),
                    ],
                    if (hasChecklist) ...[
                      Icon(Icons.check_box_outlined, size: 13, color: outline),
                      const SizedBox(width: 4),
                    ],
                    if (!hasCode && !hasAudio && !hasChecklist)
                      Icon(Icons.notes, size: 13, color: outline),
                  ],
                ),
                _buildMetaStats(isDark, outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaStats(bool isDark, Color outline) {
    final checklist = note.blocks.where((b) => b.type == BlockType.checklist).toList();
    if (checklist.isNotEmpty) {
      final done = checklist.where((b) => b.metadata['isChecked'] == true).length;
      final isAllDone = done == checklist.length;
      final doneColor = isDark ? const Color(0xFF30D158) : const Color(0xFF1E8E3E);
      return Text(
        '$done/${checklist.length} done',
        style: AppTypography.caption(
          isAllDone ? doneColor : outline,
          size: 10,
          weight: isAllDone ? FontWeight.w600 : FontWeight.w500,
        ),
      );
    }
    final words = note.wordCount;
    if (words > 0) {
      return Text(
        '$words ${words == 1 ? "word" : "words"}',
        style: AppTypography.caption(outline, size: 10),
      );
    }
    return Text(
      '${note.blocks.length} ${note.blocks.length == 1 ? "block" : "blocks"}',
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
            border: Border.all(
              color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                title: Text(note.isPinned ? 'Unpin' : 'Pin to Top'),
                onTap: () {
                  Navigator.pop(ctx);
                  onTogglePin();
                },
              ),
              if (onDuplicate != null)
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Duplicate Note'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onDuplicate!();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete Note', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
