import 'package:flutter/material.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class SegmentedTabControl extends StatelessWidget {
  final DirectoryTab activeTab;
  final ValueChanged<DirectoryTab> onTabChanged;

  const SegmentedTabControl({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final containerBg = isDark ? AppColors.darkSurfaceContainerLowest : AppColors.lightSurfaceContainerLowest;
    final activeBg = isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainer;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: TextRegistry.get(TextKey.allNotesTab),
              isSelected: activeTab == DirectoryTab.all,
              activeBg: activeBg,
              activeColor: onSurface,
              inactiveColor: onSurfaceVar,
              onTap: () => onTabChanged(DirectoryTab.all),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: TextRegistry.get(TextKey.tagsTab),
              isSelected: activeTab == DirectoryTab.tags,
              activeBg: activeBg,
              activeColor: onSurface,
              inactiveColor: onSurfaceVar,
              onTap: () => onTabChanged(DirectoryTab.tags),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color activeBg;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.activeBg,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TactileFeedback.click();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: AppTypography.title(
            isSelected ? activeColor : inactiveColor,
            size: 13,
            weight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
