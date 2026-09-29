import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class ChecklistBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final bool isSelected;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onEnterNext;

  const ChecklistBlockWidget({
    super.key,
    required this.block,
    this.isSelected = false,
    required this.onToggle,
    required this.onChanged,
    required this.onDelete,
    this.onEnterNext,
  });

  @override
  State<ChecklistBlockWidget> createState() => _ChecklistBlockWidgetState();
}

class _ChecklistBlockWidgetState extends State<ChecklistBlockWidget> {
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
  void didUpdateWidget(covariant ChecklistBlockWidget oldWidget) {
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
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final isChecked = widget.block.metadata['isChecked'] as bool? ?? false;

    final checkboxWidget = GestureDetector(
      onTap: () {
        TactileFeedback.light();
        widget.onToggle(!isChecked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isChecked ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isChecked
                ? primary
                : (isDark ? AppColors.darkOutline : AppColors.lightOutline),
            width: 1.5,
          ),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: isChecked
            ? Icon(Icons.check, size: 15, color: isDark ? AppColors.darkOnPrimary : Colors.white)
            : null,
      ),
    );

    final textFieldWidget = Expanded(
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _handleChanged,
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: _isRtl ? TextAlign.right : TextAlign.left,
        style: AppTypography.body(
          isChecked ? onSurfaceVar : onSurface,
          size: 14,
        ).copyWith(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked ? onSurfaceVar.withValues(alpha: 0.6) : onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Task description...',
          hintStyle: AppTypography.body(onSurfaceVar.withValues(alpha: 0.4), size: 14),
        ),
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => widget.onEnterNext?.call(),
      ),
    );

    final deleteButton = IconButton(
      icon: Icon(Icons.close, size: 14, color: onSurfaceVar.withValues(alpha: 0.5)),
      onPressed: () {
        TactileFeedback.light();
        widget.onDelete();
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _isRtl
            ? [
                deleteButton,
                const SizedBox(width: 8),
                textFieldWidget,
                const SizedBox(width: 10),
                checkboxWidget,
              ]
            : [
                checkboxWidget,
                const SizedBox(width: 10),
                textFieldWidget,
                const SizedBox(width: 8),
                deleteButton,
              ],
      ),
    );
  }
}
