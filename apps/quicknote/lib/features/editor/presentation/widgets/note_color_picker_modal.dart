import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class NoteColorPickerModal {
  static const Map<String, NoteColorOption> colors = {
    'none': NoteColorOption('Titanium', Color(0xFF8E8E93), Colors.transparent),
    'lavender': NoteColorOption('Lavender', Color(0xFFAF52DE), Color(0x22AF52DE)),
    'ocean': NoteColorOption('Ocean Sky', Color(0xFF007AFF), Color(0x22007AFF)),
    'emerald': NoteColorOption('Emerald Sage', Color(0xFF34C759), Color(0x2234C759)),
    'amber': NoteColorOption('Warm Amber', Color(0xFFFF9500), Color(0x22FF9500)),
    'rose': NoteColorOption('Rose Quartz', Color(0xFFFF2D55), Color(0x22FF2D55)),
  };

  static Color getAccentColor(String? key, bool isDark) {
    if (key == null || key == 'none' || !colors.containsKey(key)) {
      return isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    }
    return colors[key]!.accent;
  }

  static void show(BuildContext context, {required String? currentColor, required ValueChanged<String?> onColorSelected}) {
    TactileFeedback.click();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.98)
                : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(24),
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
                    'Note Color Theme',
                    style: AppTypography.title(onSurface, size: 16, weight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: onSurfaceVar),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: colors.entries.map((entry) {
                  final key = entry.key;
                  final opt = entry.value;
                  final isSelected = (currentColor ?? 'none') == key;
                  return GestureDetector(
                    onTap: () {
                      TactileFeedback.light();
                      Navigator.pop(ctx);
                      onColorSelected(key == 'none' ? null : key);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: opt.accent.withValues(alpha: isDark ? 0.3 : 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? opt.accent : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: opt.accent.withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isSelected
                                ? Icon(Icons.check, size: 20, color: opt.accent)
                                : Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: opt.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          opt.name,
                          style: AppTypography.caption(
                            isSelected ? onSurface : onSurfaceVar,
                            size: 10,
                            weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class NoteColorOption {
  final String name;
  final Color accent;
  final Color background;
  const NoteColorOption(this.name, this.accent, this.background);
}
