import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class BlockFormatSheet {
  static void show(BuildContext context, NoteEditorCubit cubit) {
    TactileFeedback.click();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final selectedId = cubit.state.selectedBlockId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Text Size',
                    style: AppTypography.title(onSurface, size: 16, weight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: onSurfaceVar),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildSizeOption(
                context: ctx,
                cubit: cubit,
                selectedId: selectedId,
                title: 'Title',
                subtitle: 'Large primary section heading',
                size: 24.0,
                icon: Icons.title,
                primaryColor: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
              ),
              _buildSizeOption(
                context: ctx,
                cubit: cubit,
                selectedId: selectedId,
                title: 'Heading',
                subtitle: 'Major topic and key callout',
                size: 20.0,
                icon: Icons.text_fields,
                primaryColor: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
              ),
              _buildSizeOption(
                context: ctx,
                cubit: cubit,
                selectedId: selectedId,
                title: 'Subheading',
                subtitle: 'Medium emphasis subtitle',
                size: 17.0,
                icon: Icons.short_text,
                primaryColor: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
              ),
              _buildSizeOption(
                context: ctx,
                cubit: cubit,
                selectedId: selectedId,
                title: 'Body',
                subtitle: 'Standard paragraph text size',
                size: 15.0,
                icon: Icons.notes,
                primaryColor: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
              ),
              _buildSizeOption(
                context: ctx,
                cubit: cubit,
                selectedId: selectedId,
                title: 'Caption',
                subtitle: 'Small notes and annotations',
                size: 12.0,
                icon: Icons.subtitles_outlined,
                primaryColor: primary,
                onSurface: onSurface,
                onSurfaceVar: onSurfaceVar,
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSizeOption({
    required BuildContext context,
    required NoteEditorCubit cubit,
    required String? selectedId,
    required String title,
    required String subtitle,
    required double size,
    required IconData icon,
    required Color primaryColor,
    required Color onSurface,
    required Color onSurfaceVar,
  }) {
    return InkWell(
      onTap: () {
        TactileFeedback.light();
        Navigator.pop(context);
        if (selectedId != null) {
          cubit.updateBlockMetadata(selectedId, {'fontSize': size});
        } else {
          cubit.addBlock(
            BlockType.paragraph,
            content: '',
            metadata: {'fontSize': size},
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: primaryColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(onSurface, size: 14, weight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption(onSurfaceVar, size: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${size.toInt()}pt',
                style: AppTypography.caption(primaryColor, size: 11, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
