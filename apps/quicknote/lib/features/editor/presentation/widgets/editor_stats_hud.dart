import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class EditorStatsHud extends StatelessWidget {
  final Note note;

  const EditorStatsHud({super.key, required this.note});

  int get _charCount {
    int count = 0;
    for (final block in note.blocks) {
      count += block.content.length;
    }
    return count;
  }

  String get _readingTime {
    final words = note.wordCount;
    if (words <= 30) return '< 1 min read';
    final mins = (words / 180).ceil();
    return '$mins min read';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final words = note.wordCount;
    final chars = _charCount;
    final readTime = _readingTime;

    final checklist = note.blocks.where((b) => b.type == BlockType.checklist).toList();
    final doneTasks = checklist.where((b) => b.metadata['isChecked'] == true).length;

    return GestureDetector(
      onTap: () {
        TactileFeedback.light();
        _showStatsDetails(context, words, chars, readTime, checklist.length, doneTasks);
      },
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        customBackground: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.8),
        borderColor: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.query_stats_rounded, size: 14, color: primary),
            const SizedBox(width: 6),
            Text(
              '$words words • $readTime',
              style: AppTypography.caption(onSurfaceVar, size: 11, weight: FontWeight.w500),
            ),
            if (checklist.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(shape: BoxShape.circle, color: onSurfaceVar),
              ),
              const SizedBox(width: 6),
              Text(
                '✓ $doneTasks/${checklist.length}',
                style: AppTypography.caption(
                  doneTasks == checklist.length ? const Color(0xFF34C759) : onSurfaceVar,
                  size: 11,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatsDetails(
    BuildContext context,
    int words,
    int chars,
    String readTime,
    int totalTasks,
    int doneTasks,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reading & Note Statistics', style: AppTypography.title(onSurface, size: 16)),
            const SizedBox(height: 16),
            _statRow('Word Count', '$words', onSurface, onSurfaceVar),
            _statRow('Character Count', '$chars', onSurface, onSurfaceVar),
            _statRow('Estimated Read Time', readTime, onSurface, onSurfaceVar),
            if (totalTasks > 0)
              _statRow('Tasks Completed', '$doneTasks of $totalTasks (${((doneTasks / totalTasks) * 100).toInt()}%)', onSurface, onSurfaceVar),
            _statRow('Total Blocks', '${note.blocks.length}', onSurface, onSurfaceVar),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color onSurface, Color onSurfaceVar) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: onSurfaceVar, fontSize: 13)),
          Text(value, style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
