import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';
import '../note_metadata_dialogs.dart';

class TitleBlockWidget extends StatefulWidget {
  final String title;
  final String category;
  final List<String> tags;
  final Set<String> existingCategories;
  final Set<String> existingTags;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<List<String>> onTagsChanged;

  const TitleBlockWidget({
    super.key,
    required this.title,
    required this.category,
    required this.tags,
    this.existingCategories = const {},
    this.existingTags = const {},
    required this.onTitleChanged,
    required this.onCategoryChanged,
    required this.onTagsChanged,
  });

  @override
  State<TitleBlockWidget> createState() => _TitleBlockWidgetState();
}

class _TitleBlockWidgetState extends State<TitleBlockWidget> {
  late TextEditingController _titleController;
  bool _isRtl = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _isRtl = isRtlText(_titleController.text);
  }

  @override
  void didUpdateWidget(covariant TitleBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title && _titleController.text != widget.title) {
      _titleController.text = widget.title;
      final newRtl = isRtlText(_titleController.text);
      if (newRtl != _isRtl) {
        setState(() => _isRtl = newRtl);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleTitleChanged(String val) {
    final newRtl = isRtlText(val);
    if (newRtl != _isRtl) {
      setState(() => _isRtl = newRtl);
    }
    widget.onTitleChanged(val);
  }

  Color _colorForCategory(String cat, bool isDark) {
    final c = cat.toLowerCase();
    if (c == 'work' || c == 'business') return const Color(0xFF0A84FF);
    if (c.contains('strategy') || c == 'ideas') return const Color(0xFFFF9F0A);
    if (c == 'personal' || c == 'life') return const Color(0xFFFF375F);
    if (c == 'code' || c == 'tech' || c == 'swiftui') return const Color(0xFF30D158);
    if (c == 'architecture' || c == 'design') return const Color(0xFFBF5AF2);
    return isDark ? const Color(0xFFAAC7FF) : const Color(0xFF005AC1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final displayCat = widget.category.isEmpty ? 'General' : widget.category;
    final catColor = _colorForCategory(displayCat, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pill (Tap to change)
        GestureDetector(
          onTap: () => NoteMetadataDialogs.showChangeCategory(
            context: context,
            currentCategory: widget.category,
            existingCategories: widget.existingCategories,
            onSelected: widget.onCategoryChanged,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: catColor.withValues(alpha: isDark ? 0.35 : 0.22),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_outlined, size: 13, color: catColor),
                const SizedBox(width: 5),
                Text(
                  displayCat,
                  style: AppTypography.caption(catColor, size: 11, weight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(Icons.edit_outlined, size: 11, color: catColor.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Title Input (Fixed at top, with automatic Persian RTL / English LTR support)
        TextField(
          controller: _titleController,
          onChanged: _handleTitleChanged,
          maxLines: null,
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          textAlign: _isRtl ? TextAlign.right : TextAlign.left,
          style: AppTypography.display(onSurface, size: 28, weight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Note Title...',
            hintStyle: AppTypography.display(
              onSurfaceVar.withValues(alpha: 0.45),
              size: 28,
              weight: FontWeight.w500,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 10),
        // Tags Row
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...widget.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$tag',
                      style: AppTypography.caption(primary, size: 11, weight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        TactileFeedback.light();
                        widget.onTagsChanged(widget.tags.where((t) => t != tag).toList());
                      },
                      child: Icon(Icons.close, size: 12, color: onSurfaceVar.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              );
            }),
            // Quick Add Tag Button
            GestureDetector(
              onTap: () => NoteMetadataDialogs.showAddTag(
                context: context,
                currentTags: widget.tags,
                existingTags: widget.existingTags,
                onTagsChanged: widget.onTagsChanged,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 12, color: onSurfaceVar),
                    const SizedBox(width: 3),
                    Text(
                      'Tag',
                      style: AppTypography.caption(onSurfaceVar, size: 11, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
