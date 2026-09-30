import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class HeadingBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const HeadingBlockWidget({
    super.key,
    required this.block,
    this.isSelected = false,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<HeadingBlockWidget> createState() => _HeadingBlockWidgetState();
}

class _HeadingBlockWidgetState extends State<HeadingBlockWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isRtl = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
    _focusNode = FocusNode();
    _isRtl = isRtlText(_controller.text);

    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.backspace &&
          _controller.text.isEmpty) {
        TactileFeedback.light();
        widget.onDelete();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    if (widget.isSelected || widget.block.content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HeadingBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _focusNode.requestFocus();
    }
    if (oldWidget.block.content != widget.block.content &&
        _controller.text != widget.block.content) {
      _controller.text = widget.block.content;
      final newRtl = isRtlText(_controller.text);
      if (newRtl != _isRtl) {
        setState(() => _isRtl = newRtl);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    final newRtl = isRtlText(value);
    if (newRtl != _isRtl) {
      setState(() => _isRtl = newRtl);
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final fontSize = (widget.block.metadata['fontSize'] as num?)?.toDouble() ?? 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _handleChanged,
              textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
              textAlign: _isRtl ? TextAlign.right : TextAlign.left,
              style: AppTypography.headline(
                onSurface,
                size: fontSize,
                weight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: TextRegistry.get(TextKey.addHeading),
                hintStyle: AppTypography.headline(
                  onSurfaceVar.withValues(alpha: 0.5),
                  size: fontSize,
                  weight: FontWeight.w600,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: onSurfaceVar.withValues(alpha: 0.5)),
            onPressed: () {
              TactileFeedback.light();
              widget.onDelete();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}
