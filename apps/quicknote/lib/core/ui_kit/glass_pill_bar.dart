import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassPillBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;

  const GlassPillBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.88)
        : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.88);
    final border = isDark ? AppColors.darkHairlineTop : AppColors.lightHairlineTop;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 420),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: border, width: 0.5),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
