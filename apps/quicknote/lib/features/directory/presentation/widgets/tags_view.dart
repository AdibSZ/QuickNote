import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class TagsView extends StatelessWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return BlocBuilder<NotesDirectoryCubit, NotesDirectoryState>(
      builder: (context, state) {
        final tags = state.availableTags;
        if (tags.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.label_outline, size: 36, color: onSurfaceVar.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('No tags yet', style: AppTypography.title(onSurface, size: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'Tag notes using the + Tag chip in the editor to organize them here.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(onSurfaceVar, size: 11),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.selectedTag != null
                        ? 'Notes with #${state.selectedTag}:'
                        : 'Filter by Tag (${tags.length} tags):',
                    style: AppTypography.caption(primary, size: 12, weight: FontWeight.w600),
                  ),
                  if (state.selectedTag != null)
                    GestureDetector(
                      onTap: () {
                        TactileFeedback.click();
                        context.read<NotesDirectoryCubit>().selectTag(null);
                      },
                      child: Text('Clear Filter', style: AppTypography.caption(Colors.redAccent, size: 11)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final isSelected = state.selectedTag?.toLowerCase() == tag.toLowerCase();
                  final count = state.allNotes.where((n) => n.tags.contains(tag)).length;

                  return GestureDetector(
                    onTap: () {
                      TactileFeedback.click();
                      context.read<NotesDirectoryCubit>().selectTag(tag);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.darkPrimaryContainer.withValues(alpha: 0.4) : AppColors.lightPrimaryContainer)
                            : (isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isSelected ? primary : (isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder),
                          width: isSelected ? 1.0 : 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#$tag', style: AppTypography.title(isSelected ? onSurface : onSurfaceVar, size: 12)),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? primary.withValues(alpha: 0.25) : (isDark ? Colors.white10 : Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$count', style: AppTypography.caption(onSurfaceVar, size: 10)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
