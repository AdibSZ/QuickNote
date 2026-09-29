import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'tactile_feedback.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? customBackground;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.customBackground,
    this.borderColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    final hoverBorderColor = isDark
        ? const Color(0xFFAAC7FF).withValues(alpha: 0.45)
        : const Color(0xFF005AC1).withValues(alpha: 0.35);

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onExit: isInteractive ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          TactileFeedback.light();
          widget.onTap?.call();
        },
        onLongPress: () {
          TactileFeedback.medium();
          widget.onLongPress?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value * (_isHovered ? 1.015 : 1.0),
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            child: GlassContainer(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              padding: widget.padding,
              customBackground: widget.customBackground,
              customBorderColor: _isHovered ? hoverBorderColor : widget.borderColor,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
