import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class AudioControlButtons extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleRecord;
  final Color primary;
  final Color onPrimary;
  final Color onSurfaceVar;
  final bool isDark;

  const AudioControlButtons({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onToggleRecord,
    required this.primary,
    required this.onPrimary,
    required this.onSurfaceVar,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isRecording ? Colors.grey.shade400 : primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 20,
              color: onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onToggleRecord,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isRecording
                  ? const Color(0xFFFF453A)
                  : (isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.mic_none,
              size: 18,
              color: isRecording ? Colors.white : onSurfaceVar,
            ),
          ),
        ),
      ],
    );
  }
}
