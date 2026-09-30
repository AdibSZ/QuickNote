import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class MobileBottomDock extends StatelessWidget {
  final String selectedCategory;
  final int allCount;
  final int favoritesCount;
  final int trashCount;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onOpenTags;

  const MobileBottomDock({
    super.key,
    required this.selectedCategory,
    required this.allCount,
    required this.favoritesCount,
    required this.trashCount,
    required this.onSelectCategory,
    required this.onOpenTags,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final bg = isDark
        ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.94)
        : AppColors.lightSurfaceContainerLowest.withValues(alpha: 0.94);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dockItem(
            icon: Icons.notes_rounded,
            label: 'Notes',
            count: allCount,
            isSelected: selectedCategory == 'All',
            activeColor: primary,
            onSurfaceVar: onSurfaceVar,
            onSurface: onSurface,
            onTap: () => onSelectCategory('All'),
          ),
          _dockItem(
            icon: Icons.star_rounded,
            label: 'Favorites',
            count: favoritesCount,
            isSelected: selectedCategory == 'Favorites',
            activeColor: const Color(0xFFFFCC00),
            onSurfaceVar: onSurfaceVar,
            onSurface: onSurface,
            onTap: () => onSelectCategory('Favorites'),
          ),
          _dockItem(
            icon: Icons.tag_rounded,
            label: 'Tags',
            count: null,
            isSelected: false,
            activeColor: primary,
            onSurfaceVar: onSurfaceVar,
            onSurface: onSurface,
            onTap: onOpenTags,
          ),
          if (trashCount > 0)
            _dockItem(
              icon: Icons.delete_outline_rounded,
              label: 'Trash',
              count: trashCount,
              isSelected: selectedCategory == 'Trash',
              activeColor: Colors.redAccent,
              onSurfaceVar: onSurfaceVar,
              onSurface: onSurface,
              onTap: () => onSelectCategory('Trash'),
            ),
        ],
      ),
    );
  }

  Widget _dockItem({
    required IconData icon,
    required String label,
    required int? count,
    required bool isSelected,
    required Color activeColor,
    required Color onSurfaceVar,
    required Color onSurface,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? activeColor : onSurfaceVar.withValues(alpha: 0.7);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        TactileFeedback.selection();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.title(color, size: 12, weight: FontWeight.w600),
              ),
            ],
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withValues(alpha: 0.18) : onSurfaceVar.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.caption(isSelected ? activeColor : onSurfaceVar, size: 9, weight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
