import 'package:flutter/material.dart';
import 'package:quicknote_core/quicknote_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class MobileSpeedDialFab extends StatefulWidget {
  final VoidCallback onNewTextNote;
  final VoidCallback onNewChecklistNote;
  final VoidCallback onNewAudioNote;

  const MobileSpeedDialFab({
    super.key,
    required this.onNewTextNote,
    required this.onNewChecklistNote,
    required this.onNewAudioNote,
  });

  @override
  State<MobileSpeedDialFab> createState() => _MobileSpeedDialFabState();
}

class _MobileSpeedDialFabState extends State<MobileSpeedDialFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    TactileFeedback.selection();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _anim.forward();
      } else {
        _anim.reverse();
      }
    });
  }

  void _closeAnd(VoidCallback action) {
    TactileFeedback.click();
    _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final onPrimary = isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
    final bgSurface = isDark
        ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.95)
        : AppColors.lightSurfaceContainerHighest.withValues(alpha: 0.95);
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildActionPill(
            icon: Icons.mic_rounded,
            label: TextRegistry.get(TextKey.voiceMemo),
            color: const Color(0xFFFF9500),
            bgSurface: bgSurface,
            onSurface: onSurface,
            onTap: () => _closeAnd(widget.onNewAudioNote),
          ),
          const SizedBox(height: 10),
          _buildActionPill(
            icon: Icons.check_box_outlined,
            label: TextRegistry.get(TextKey.toDoList),
            color: const Color(0xFF34C759),
            bgSurface: bgSurface,
            onSurface: onSurface,
            onTap: () => _closeAnd(widget.onNewChecklistNote),
          ),
          const SizedBox(height: 10),
          _buildActionPill(
            icon: Icons.edit_note_rounded,
            label: TextRegistry.get(TextKey.addBlock),
            color: primary,
            bgSurface: bgSurface,
            onSurface: onSurface,
            onTap: () => _closeAnd(widget.onNewTextNote),
          ),
          const SizedBox(height: 14),
        ],
        FloatingActionButton(
          elevation: 4,
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: const CircleBorder(),
          onPressed: _toggle,
          child: RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 0.125).animate(
              CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
            ),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgSurface,
    required Color onSurface,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.title(onSurface, size: 13, weight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
