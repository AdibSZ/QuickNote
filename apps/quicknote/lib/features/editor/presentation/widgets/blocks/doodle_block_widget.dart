import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';
import 'doodle_canvas_modal.dart';

class DoodleBlockWidget extends StatelessWidget {
  final NoteBlock block;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onDelete;

  const DoodleBlockWidget({
    super.key,
    required this.block,
    required this.onContentChanged,
    required this.onDelete,
  });

  void _openEditor(BuildContext context) {
    TactileFeedback.medium();
    DoodleCanvasModal.show(
      context,
      initialData: block.content,
      onSave: (newData) {
        onContentChanged(newData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strokes = DoodleStroke.parseStrokes(block.content);
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.draw_outlined, size: 16, color: onSurfaceVar),
                const SizedBox(width: 8),
                Text(
                  'Sketch / Doodle',
                  style: AppTypography.caption(onSurfaceVar).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: onSurfaceVar,
                  tooltip: 'Edit Sketch',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => _openEditor(context),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: onSurfaceVar,
                  tooltip: 'Remove',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () {
                    TactileFeedback.light();
                    onDelete();
                  },
                ),
              ],
            ),
          ),
          // Canvas preview
          GestureDetector(
            onTap: () => _openEditor(context),
            child: Container(
              height: 180,
              color: isDark ? const Color(0xFF18181B) : const Color(0xFFF3F4F6),
              child: strokes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gesture, size: 28, color: onSurfaceVar.withValues(alpha: 0.5)),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to sketch or doodle',
                            style: AppTypography.caption(onSurfaceVar.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    )
                  : ClipRect(
                      child: CustomPaint(
                        painter: DoodlePainter(strokes, fit: true),
                        size: Size.infinite,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
