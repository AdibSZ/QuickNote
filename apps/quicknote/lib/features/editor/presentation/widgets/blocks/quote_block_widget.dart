import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class QuoteBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const QuoteBlockWidget({
    super.key,
    required this.block,
    required this.isSelected,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<QuoteBlockWidget> createState() => _QuoteBlockWidgetState();
}

class _QuoteBlockWidgetState extends State<QuoteBlockWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
  }

  @override
  void didUpdateWidget(covariant QuoteBlockWidget oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final isRtl = isRtlText(_controller.text);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.8 : 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: _controller,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: AppTypography.body(onSurface.withValues(alpha: 0.9), size: 16, fontStyle: FontStyle.italic).copyWith(
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Quote or thought...',
                    hintStyle: AppTypography.body(onSurfaceVar.withValues(alpha: 0.4), size: 16, fontStyle: FontStyle.italic),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 16, color: onSurfaceVar.withValues(alpha: 0.5)),
              tooltip: 'Delete Quote',
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
