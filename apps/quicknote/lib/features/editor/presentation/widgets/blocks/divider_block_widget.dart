import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class DividerBlockWidget extends StatelessWidget {
  final NoteBlock block;
  final VoidCallback onDelete;

  const DividerBlockWidget({
    super.key,
    required this.block,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.6)
        : AppColors.lightBorder.withValues(alpha: 0.6);
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: dividerColor,
              thickness: 1,
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.more_horiz,
              size: 14,
              color: onSurfaceVar.withValues(alpha: 0.35),
            ),
          ),
          Expanded(
            child: Divider(
              color: dividerColor,
              thickness: 1,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.close, size: 14, color: onSurfaceVar.withValues(alpha: 0.4)),
            tooltip: 'Delete Divider',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () {
              TactileFeedback.light();
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
