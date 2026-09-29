import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class SortOptionsModal {
  static void show(BuildContext context) {
    TactileFeedback.click();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final cubit = context.read<NotesDirectoryCubit>();
    final currentOrder = cubit.state.sortOrder;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerHighest
                : AppColors.lightSurfaceContainerHighest,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort Notes By',
                    style: AppTypography.title(onSurface, size: 16, weight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: onSurfaceVar),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildOption(
                title: 'Date Modified',
                subtitle: 'Most recently edited notes first',
                icon: Icons.update,
                order: NoteSortOrder.updatedDesc,
                current: currentOrder,
                primary: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
                onSelect: () {
                  TactileFeedback.light();
                  cubit.setSortOrder(NoteSortOrder.updatedDesc);
                  Navigator.pop(ctx);
                },
              ),
              _buildOption(
                title: 'Date Created',
                subtitle: 'Newest created notes first',
                icon: Icons.calendar_today_outlined,
                order: NoteSortOrder.createdDesc,
                current: currentOrder,
                primary: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
                onSelect: () {
                  TactileFeedback.light();
                  cubit.setSortOrder(NoteSortOrder.createdDesc);
                  Navigator.pop(ctx);
                },
              ),
              _buildOption(
                title: 'Title',
                subtitle: 'Alphabetical order (A to Z)',
                icon: Icons.sort_by_alpha,
                order: NoteSortOrder.titleAsc,
                current: currentOrder,
                primary: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
                onSelect: () {
                  TactileFeedback.light();
                  cubit.setSortOrder(NoteSortOrder.titleAsc);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required NoteSortOrder order,
    required NoteSortOrder current,
    required Color primary,
    required Color onSurface,
    required Color onSurfaceVar,
    required VoidCallback onSelect,
  }) {
    final isSelected = order == current;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isSelected ? primary : onSurfaceVar),
      ),
      title: Text(
        title,
        style: AppTypography.body(
          isSelected ? primary : onSurface,
          size: 14,
          weight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption(onSurfaceVar.withValues(alpha: 0.7), size: 11),
      ),
      trailing: isSelected ? Icon(Icons.check, size: 18, color: primary) : null,
      onTap: onSelect,
    );
  }
}
