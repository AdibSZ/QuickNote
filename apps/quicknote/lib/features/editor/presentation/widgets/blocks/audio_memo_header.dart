import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class AudioMemoHeader extends StatelessWidget {
  final TextEditingController titleController;
  final bool isRecording;
  final String displayTime;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVar;
  final bool isDark;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onDelete;

  const AudioMemoHeader({
    super.key,
    required this.titleController,
    required this.isRecording,
    required this.displayTime,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVar,
    required this.isDark,
    required this.onTitleChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final titleRtl = isRtlText(titleController.text);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isRecording ? const Color(0xFFFF453A) : primary,
                  shape: BoxShape.circle,
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF453A).withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: titleController,
                  onChanged: onTitleChanged,
                  textDirection: titleRtl ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: titleRtl ? TextAlign.right : TextAlign.left,
                  style: AppTypography.title(onSurface, size: 14, weight: FontWeight.w600),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Voice Note Title...',
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isRecording
                    ? const Color(0xFFFF453A).withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayTime,
                style: AppTypography.caption(
                  isRecording ? const Color(0xFFFF453A) : onSurfaceVar,
                  size: 11,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                TactileFeedback.light();
                onDelete();
              },
              child: Icon(Icons.close, size: 16, color: onSurfaceVar.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }
}
