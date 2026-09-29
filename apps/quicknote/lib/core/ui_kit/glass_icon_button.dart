import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tactile_feedback.dart';

class GlassIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isSelected;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isSelected = false,
    this.size = 40,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = widget.isSelected
        ? (isDark ? AppColors.darkPrimaryContainer.withValues(alpha: 0.25) : AppColors.lightPrimaryContainer)
        : (_isPressed
            ? (isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest)
            : Colors.transparent);

    final border = widget.isSelected
        ? (isDark ? AppColors.darkPrimary.withValues(alpha: 0.5) : AppColors.lightPrimary.withValues(alpha: 0.5))
        : Colors.transparent;

    Widget btn = GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed != null
          ? () {
              TactileFeedback.click();
              widget.onPressed!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 0.5),
        ),
        child: Center(child: widget.icon),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}
