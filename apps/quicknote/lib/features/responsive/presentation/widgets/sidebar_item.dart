import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ResponsiveSidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const ResponsiveSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
        : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.title(color, size: 13, weight: isSelected ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
            if (count != null)
              Text(
                '$count',
                style: AppTypography.caption(color, size: 11),
              ),
          ],
        ),
      ),
    );
  }
}
