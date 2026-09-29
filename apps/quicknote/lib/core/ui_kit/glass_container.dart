import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? customBackground;
  final Color? customBorderColor;
  final double borderWidth;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.customBackground,
    this.customBorderColor,
    this.borderWidth = 0.5,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? BorderRadius.circular(12);

    final bg = customBackground ??
        (isDark
            ? AppColors.darkSurfaceContainerLow.withValues(alpha: 0.65)
            : AppColors.lightSurfaceContainerLowest.withValues(alpha: 0.75));

    final borderColor = customBorderColor ??
        (isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(color: borderColor, width: borderWidth),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    Colors.white.withValues(alpha: isDark ? 0.07 : 0.18),
                    bg,
                  ),
                  bg,
                ],
                stops: const [0.0, 0.6],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
