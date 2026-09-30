import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';
import 'package:url_launcher/url_launcher.dart';

typedef BlockTransformCallback = void Function(
  BlockType newType,
  String newContent,
  Map<String, dynamic>? metadata,
);

class ParagraphBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final BlockTransformCallback? onTransform;

  const ParagraphBlockWidget({
    super.key,
    required this.block,
    required this.isSelected,
    required this.onChanged,
    required this.onTap,
    this.onDelete,
    this.onTransform,
  });

  @override
  State<ParagraphBlockWidget> createState() => _ParagraphBlockWidgetState();
}

class _ParagraphBlockWidgetState extends State<ParagraphBlockWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isRtl = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isRtl = isRtlText(_controller.text);

    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.backspace &&
          _controller.text.isEmpty) {
        widget.onDelete?.call();
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
  void didUpdateWidget(covariant ParagraphBlockWidget oldWidget) {
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

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    if (widget.onTransform != null) {
      if (value.startsWith('# ') || value.startsWith('## ')) {
        final headingText = value.startsWith('## ') ? value.substring(3) : value.substring(2);
        TactileFeedback.medium();
        widget.onTransform!(BlockType.heading2, headingText, {'fontSize': 20.0});
        return;
      }
      if (value.startsWith('- ') || value.startsWith('* ') || value.startsWith('[] ')) {
        final taskText = value.replaceFirst(RegExp(r'^(\-\s|\*\s|\[\]\s)'), '');
        TactileFeedback.medium();
        widget.onTransform!(BlockType.checklist, taskText, {'isChecked': false});
        return;
      }
      if (value.startsWith('> ')) {
        final quoteText = value.substring(2);
        TactileFeedback.medium();
        widget.onTransform!(BlockType.quote, quoteText, {});
        return;
      }
      if (value.startsWith('! ') || value.startsWith('💡 ')) {
        final calloutText = value.startsWith('💡 ') ? value.substring(3) : value.substring(2);
        TactileFeedback.medium();
        widget.onTransform!(BlockType.callout, calloutText, {'icon': '💡', 'tint': 'amber'});
        return;
      }
      if (value.startsWith('---') || value.startsWith('***')) {
        TactileFeedback.medium();
        widget.onTransform!(BlockType.divider, '', {});
        return;
      }
      if (value.startsWith('```')) {
        final codeText = value.length > 3 ? value.substring(3).trimLeft() : '';
        TactileFeedback.medium();
        widget.onTransform!(BlockType.codeBlock, codeText, {'language': 'DART'});
        return;
      }
    }

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

    final fontSize = (widget.block.metadata['fontSize'] as num?)?.toDouble() ?? 15.0;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        _focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? (isDark
                  ? AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.3)
                  : AppColors.lightSurfaceContainer.withValues(alpha: 0.6))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _handleChanged,
                    maxLines: null,
                    textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: _isRtl ? TextAlign.right : TextAlign.left,
                    style: AppTypography.body(onSurface, size: fontSize),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: _focusNode.hasFocus ? '' : TextRegistry.get(TextKey.typeTextHere),
                      hintStyle: AppTypography.body(onSurfaceVar.withValues(alpha: 0.4), size: fontSize),
                    ),
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.close, size: 14, color: onSurfaceVar.withValues(alpha: 0.4)),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    tooltip: 'Delete block',
                  ),
              ],
            ),
            _buildActionChips(isDark ? AppColors.darkPrimary : AppColors.lightPrimary, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChips(Color primary, bool isDark) {
    final text = _controller.text;
    final urlReg = RegExp(r'https?://[^\s]+|www\.[^\s]+', caseSensitive: false);
    final phoneReg = RegExp(r'(?:\+?[0-9]{1,3}[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}');
    final urls = urlReg.allMatches(text).map((m) => m.group(0)!).toSet().toList();
    final phones = phoneReg.allMatches(text).map((m) => m.group(0)!).toSet().toList();

    if (urls.isEmpty && phones.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          ...urls.map((url) {
            final target = url.startsWith('http') ? url : 'https://$url';
            return ActionChip(
              avatar: Icon(Icons.open_in_new, size: 12, color: primary),
              label: Text(url, style: TextStyle(fontSize: 10.5, color: primary, fontWeight: FontWeight.w600)),
              backgroundColor: primary.withValues(alpha: isDark ? 0.15 : 0.08),
              side: BorderSide(color: primary.withValues(alpha: 0.25), width: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                TactileFeedback.selection();
                final uri = Uri.tryParse(target);
                if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            );
          }),
          ...phones.map((phone) {
            final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            return ActionChip(
              avatar: const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF10B981)),
              label: Text(phone, style: const TextStyle(fontSize: 10.5, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
              side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.25), width: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                TactileFeedback.selection();
                final uri = Uri.tryParse('tel:$clean');
                if (uri != null) await launchUrl(uri);
              },
            );
          }),
        ],
      ),
    );
  }
}
