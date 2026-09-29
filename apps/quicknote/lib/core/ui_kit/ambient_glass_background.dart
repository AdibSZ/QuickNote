import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean Apple-style serene neutral canvas background.
/// Pure, distraction-free neutral backdrop true to Apple Notes, Pages, and macOS design.
class AmbientGlassBackground extends StatelessWidget {
  final Widget child;

  const AmbientGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return ColoredBox(
      color: bg,
      child: child,
    );
  }
}
