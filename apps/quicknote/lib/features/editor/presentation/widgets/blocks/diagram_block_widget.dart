import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class DiagramBlockWidget extends StatelessWidget {
  final NoteBlock block;

  const DiagramBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceContainerLowest : AppColors.lightSurfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.8) : AppColors.lightSurface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Vector Graph',
                      style: AppTypography.caption(primary, size: 9),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DiagramNode(title: 'SQLite', subtitle: 'Local WAL', isPrimary: false, isDark: isDark),
                      Icon(Icons.arrow_forward, size: 16, color: primary),
                      _DiagramNode(title: 'CRDT Core', subtitle: 'Vector Clocks', isPrimary: true, isDark: isDark),
                      Icon(Icons.arrow_forward, size: 16, color: primary),
                      _DiagramNode(title: 'Cloud', subtitle: 'Sync', isPrimary: false, isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              block.content,
              textAlign: TextAlign.center,
              style: AppTypography.body(onSurfaceVar, size: 11).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPrimary;
  final bool isDark;

  const _DiagramNode({
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary
        ? (isDark ? AppColors.darkSurfaceContainerHigh : AppColors.lightSurfaceContainerHigh)
        : (isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary) : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.title(isDark ? Colors.white : Colors.black87, size: 11, weight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption(isDark ? AppColors.darkOutline : AppColors.lightOutline, size: 9),
          ),
        ],
      ),
    );
  }
}
