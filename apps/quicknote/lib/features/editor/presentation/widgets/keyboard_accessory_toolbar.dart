import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class KeyboardAccessoryToolbar extends StatelessWidget {
  final NoteEditorCubit cubit;

  const KeyboardAccessoryToolbar({
    super.key,
    required this.cubit,
  });

  String _getFormattedDate() {
    final now = DateTime.now();
    final y = now.year;
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$y/$m/$d - $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            _ToolItem(
              icon: Icons.check_box_outlined,
              label: 'چک‌لیست',
              color: primary,
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.checklist, content: '', metadata: {'isChecked': false});
              },
            ),
            _ToolItem(
              icon: Icons.today_outlined,
              label: 'تاریخ روز',
              color: const Color(0xFF34C759),
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.paragraph, content: '📅 ${_getFormattedDate()}');
              },
            ),
            _ToolItem(
              icon: Icons.lightbulb_outline,
              label: 'ایده',
              color: const Color(0xFFFF9500),
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.callout, content: '', metadata: {'icon': '💡'});
              },
            ),
            _ToolItem(
              icon: Icons.format_quote_rounded,
              label: 'نقل‌قول',
              color: const Color(0xFFAF52DE),
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.quote, content: '');
              },
            ),
            _ToolItem(
              icon: Icons.mic_none_rounded,
              label: 'صدا',
              color: Colors.redAccent,
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.audioMemo, content: 'Voice Note', metadata: {'durationSeconds': 0});
              },
            ),
            _ToolItem(
              icon: Icons.title_rounded,
              label: 'عنوان',
              color: onSurface,
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.heading2, content: '');
              },
            ),
            _ToolItem(
              icon: Icons.code_rounded,
              label: 'کد',
              color: const Color(0xFF5856D6),
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.codeBlock, content: '', metadata: {'language': 'DART'});
              },
            ),
            _ToolItem(
              icon: Icons.horizontal_rule_rounded,
              label: 'خط جداکننده',
              color: onSurfaceVar,
              onTap: () {
                TactileFeedback.light();
                cubit.addBlock(BlockType.divider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.caption(color, size: 11, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
