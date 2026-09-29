import 'package:flutter/material.dart';
import 'package:quicknote_core/quicknote_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class SearchSpotlightBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String initialValue;
  final VoidCallback? onTapSpotlight;

  const SearchSpotlightBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.onTapSpotlight,
  });

  @override
  State<SearchSpotlightBar> createState() => _SearchSpotlightBarState();
}

class _SearchSpotlightBarState extends State<SearchSpotlightBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
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
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final bg = isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: outline),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                widget.onChanged(val);
                setState(() {});
              },
              textDirection: getTextDirection(_controller.text),
              textAlign: getTextAlign(_controller.text),
              style: AppTypography.body(onSurface, size: 14),
              decoration: InputDecoration(
                hintText: TextRegistry.get(TextKey.searchPlaceholder),
                hintStyle: AppTypography.body(outline, size: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                TactileFeedback.click();
                _controller.clear();
                widget.onChanged('');
                setState(() {});
              },
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12, color: outline),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                TactileFeedback.selection();
                widget.onTapSpotlight?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.lightSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '⌘K',
                  style: AppTypography.code(outline, size: 10, weight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
