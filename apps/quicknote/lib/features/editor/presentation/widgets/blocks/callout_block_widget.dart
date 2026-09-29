import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/glass_container.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class CalloutBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final Function(String icon, String tint)? onStyleChanged;
  final VoidCallback onDelete;

  const CalloutBlockWidget({
    super.key,
    required this.block,
    required this.isSelected,
    required this.onChanged,
    this.onStyleChanged,
    required this.onDelete,
  });

  @override
  State<CalloutBlockWidget> createState() => _CalloutBlockWidgetState();
}

class _CalloutBlockWidgetState extends State<CalloutBlockWidget> {
  late TextEditingController _controller;
  static const List<String> _icons = ['💡', '📌', '⚠️', '🔥', '✨', '🎯', '🚀', '❤️'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
  }

  @override
  void didUpdateWidget(covariant CalloutBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content &&
        widget.block.content != _controller.text) {
      _controller.text = widget.block.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cycleIcon() {
    TactileFeedback.light();
    final currentIcon = widget.block.metadata['icon'] as String? ?? '💡';
    final idx = _icons.indexOf(currentIcon);
    final nextIcon = _icons[(idx + 1) % _icons.length];
    final currentTint = widget.block.metadata['tint'] as String? ?? 'amber';
    widget.onStyleChanged?.call(nextIcon, currentTint);
  }

  Color _getTintColor(String tint, bool isDark) {
    switch (tint) {
      case 'ocean':
        return isDark ? const Color(0xFF007AFF) : const Color(0xFF0051A8);
      case 'emerald':
        return isDark ? const Color(0xFF34C759) : const Color(0xFF1B823B);
      case 'rose':
        return isDark ? const Color(0xFFFF2D55) : const Color(0xFFD61438);
      case 'lavender':
        return isDark ? const Color(0xFFAF52DE) : const Color(0xFF7A24A6);
      case 'amber':
      default:
        return isDark ? const Color(0xFFFF9500) : const Color(0xFFB86600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    final icon = widget.block.metadata['icon'] as String? ?? '💡';
    final tint = widget.block.metadata['tint'] as String? ?? 'amber';
    final tintColor = _getTintColor(tint, isDark);
    final isRtl = isRtlText(_controller.text);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: BorderRadius.circular(16),
        borderColor: tintColor.withValues(alpha: isDark ? 0.35 : 0.25),
        customBackground: tintColor.withValues(alpha: isDark ? 0.08 : 0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _cycleIcon,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: tintColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: AppTypography.body(onSurface, size: 15).copyWith(
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  hintText: 'Callout note or highlight...',
                  hintStyle: AppTypography.body(onSurfaceVar.withValues(alpha: 0.5), size: 15),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: widget.onChanged,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 16, color: onSurfaceVar.withValues(alpha: 0.5)),
              tooltip: 'Delete Callout',
              onPressed: () {
                TactileFeedback.light();
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
