import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';

class CodeBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onDelete;

  const CodeBlockWidget({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onLanguageChanged,
    required this.onDelete,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  late TextEditingController _controller;
  bool _copied = false;

  static const List<String> _languages = [
    'SWIFT', 'DART', 'TYPESCRIPT', 'JAVASCRIPT', 'PYTHON', 'RUST', 'SQL', 'KOTLIN', 'JSON'
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.content);
  }

  @override
  void didUpdateWidget(covariant CodeBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content &&
        _controller.text != widget.block.content) {
      _controller.text = widget.block.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCopy() {
    TactileFeedback.light();
    Clipboard.setData(ClipboardData(text: _controller.text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _selectLanguage(BuildContext context) {
    TactileFeedback.click();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((lang) {
              return ListTile(
                dense: true,
                title: Text(lang, style: AppTypography.code(isDark ? Colors.white : Colors.black87, size: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onLanguageChanged(lang);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final containerBg = isDark ? AppColors.darkSurfaceContainerLowest : AppColors.lightSurfaceContainerLowest;
    final headerBg = isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer;

    final lang = widget.block.metadata['language'] as String? ?? 'DART';

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _selectLanguage(context),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang,
                        style: AppTypography.code(primary, size: 10, weight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 14, color: primary),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _onCopy,
                      child: Row(
                        children: [
                          Icon(
                            _copied ? Icons.check : Icons.content_copy,
                            size: 13,
                            color: _copied ? Colors.greenAccent : onSurfaceVar,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _copied ? TextRegistry.get(TextKey.copiedCode) : TextRegistry.get(TextKey.copyCode),
                            style: AppTypography.caption(
                              _copied ? Colors.greenAccent : onSurfaceVar,
                              size: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        TactileFeedback.light();
                        widget.onDelete();
                      },
                      child: Icon(Icons.close, size: 14, color: onSurfaceVar.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              maxLines: null,
              style: AppTypography.code(onSurface, size: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '// Write your code here...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
