import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class CategoryFilterChips extends StatelessWidget {
  final String selectedCategory;
  final Set<String> categories;
  final ValueChanged<String> onSelected;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    this.categories = const {'All', 'Pinned'},
    required this.onSelected,
  });

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'pinned':
        return Icons.push_pin_outlined;
      case 'architecture':
        return Icons.account_tree_outlined;
      case 'audio memos':
        return Icons.mic_none_outlined;
      case 'swiftui':
      case 'code':
        return Icons.terminal_outlined;
      case 'strategy':
      case 'strategy 2025':
      case 'ideas':
        return Icons.lightbulb_outline;
      case 'work':
      case 'business':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      default:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final activeBg = isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest;
    final inactiveBg = isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow;

    final chips = <String>{'All', 'Pinned', ...categories}.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: chips.map((cat) {
          final isSelected = selectedCategory.toLowerCase() == cat.toLowerCase();
          final icon = _iconForCategory(cat);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                TactileFeedback.click();
                onSelected(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : inactiveBg,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: isSelected
                        ? (isDark
                            ? AppColors.darkPrimary.withValues(alpha: 0.35)
                            : AppColors.lightPrimary.withValues(alpha: 0.35))
                        : (isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: isSelected ? onSurface : onSurfaceVar),
                    const SizedBox(width: 5),
                    Text(
                      cat,
                      style: AppTypography.title(
                        isSelected ? onSurface : onSurfaceVar,
                        size: 12,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
