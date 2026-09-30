import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class EmptyEditorPlaceholder extends StatelessWidget {
  final VoidCallback onCreateNote;

  const EmptyEditorPlaceholder({super.key, required this.onCreateNote});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 56, color: onSurfaceVar.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No Note Selected', style: AppTypography.title(onSurface, size: 16)),
          const SizedBox(height: 6),
          Text('Create a new note to start writing', style: AppTypography.body(onSurfaceVar, size: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreateNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimary,
              foregroundColor: isDark ? AppColors.darkOnPrimaryContainer : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create New Note'),
          ),
        ],
      ),
    );
  }
}
