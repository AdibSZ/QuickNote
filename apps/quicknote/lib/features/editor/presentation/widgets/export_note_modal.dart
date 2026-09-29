import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class ExportNoteModal {
  static void show(BuildContext context, Note note) {
    TactileFeedback.click();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final words = note.wordCount;
    final chars = note.blocks.fold(0, (sum, b) => sum + b.content.length);
    final readTime = (words / 200).ceil();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerHighest
                : AppColors.lightSurfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Export & Share',
                    style: AppTypography.title(onSurface, size: 16, weight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: onSurfaceVar),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Reading Stats Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerHigh
                      : AppColors.lightSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('$words', 'Words', onSurface, onSurfaceVar),
                    _buildStatDivider(isDark),
                    _buildStatItem('$chars', 'Characters', onSurface, onSurfaceVar),
                    _buildStatDivider(isDark),
                    _buildStatItem('${readTime > 0 ? readTime : 1} min', 'Read time', onSurface, onSurfaceVar),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.code, size: 18, color: primary),
                ),
                title: Text('Copy as Markdown', style: AppTypography.body(onSurface, size: 14, weight: FontWeight.w500)),
                subtitle: Text('Full formatting with headers, tasks, and code fences', style: AppTypography.caption(onSurfaceVar.withValues(alpha: 0.7), size: 11)),
                onTap: () {
                  TactileFeedback.light();
                  Clipboard.setData(ClipboardData(text: note.toMarkdown()));
                  Navigator.pop(ctx);
                  _showToast(context, 'Copied Markdown to clipboard');
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF30D158) : const Color(0xFF1E8E3E)).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.notes, size: 18, color: isDark ? const Color(0xFF30D158) : const Color(0xFF1E8E3E)),
                ),
                title: Text('Copy as Plain Text', style: AppTypography.body(onSurface, size: 14, weight: FontWeight.w500)),
                subtitle: Text('Clean readable text without markdown symbols', style: AppTypography.caption(onSurfaceVar.withValues(alpha: 0.7), size: 11)),
                onTap: () {
                  TactileFeedback.light();
                  Clipboard.setData(ClipboardData(text: note.toPlainText()));
                  Navigator.pop(ctx);
                  _showToast(context, 'Copied Plain Text to clipboard');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildStatItem(String val, String label, Color onSurface, Color onSurfaceVar) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(val, style: AppTypography.title(onSurface, size: 13, weight: FontWeight.w600)),
        Text(label, style: AppTypography.caption(onSurfaceVar, size: 10)),
      ],
    );
  }

  static Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 20,
      color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
    );
  }

  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
