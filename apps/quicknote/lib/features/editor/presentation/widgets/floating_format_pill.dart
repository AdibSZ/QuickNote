import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class FloatingFormatPill extends StatelessWidget {
  final VoidCallback? onBold;
  final VoidCallback? onItalic;
  final VoidCallback? onHeading;
  final VoidCallback? onCode;
  final VoidCallback? onAiPolish;
  final VoidCallback? onDelete;

  const FloatingFormatPill({
    super.key,
    this.onBold,
    this.onItalic,
    this.onHeading,
    this.onCode,
    this.onAiPolish,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.95)
        : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.95);
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final border = isDark ? AppColors.darkHairlineTop : AppColors.lightHairlineTop;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Btn(label: 'B', isBold: true, onTap: onBold, color: onSurface),
              _Btn(label: 'I', isItalic: true, onTap: onItalic, color: onSurface),
              Container(width: 1, height: 14, color: AppColors.darkOutlineVariant.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(horizontal: 4)),
              _Btn(label: 'H2', onTap: onHeading, color: primary),
              _Btn(icon: Icons.code, onTap: onCode, color: onSurface),
              _Btn(icon: Icons.auto_fix_high, onTap: onAiPolish, color: primary),
              if (onDelete != null) ...[
                Container(width: 1, height: 14, color: AppColors.darkOutlineVariant.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(horizontal: 4)),
                _Btn(icon: Icons.delete_outline, onTap: onDelete, color: Colors.redAccent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isBold;
  final bool isItalic;
  final VoidCallback? onTap;
  final Color color;

  const _Btn({
    this.label,
    this.icon,
    this.isBold = false,
    this.isItalic = false,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        TactileFeedback.click();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 14, color: color)
            : Text(
                label!,
                style: AppTypography.title(
                  color,
                  size: 12,
                  weight: isBold ? FontWeight.bold : FontWeight.w500,
                ).copyWith(fontStyle: isItalic ? FontStyle.italic : null),
              ),
      ),
    );
  }
}
