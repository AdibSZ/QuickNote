import 'package:flutter/material.dart';
import 'package:quicknote_core/quicknote_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/app_emblem.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../../core/ui_kit/glass_icon_button.dart';
import 'editor_more_menu_sheet.dart';

class EditorHeader extends StatelessWidget {
  final VoidCallback onBack;
  final bool isSaving;
  final String noteTitle;
  final bool isPinned;
  final bool isFavorite;
  final bool isLocked;
  final String? noteColor;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onToggleLock;
  final VoidCallback? onPickColor;
  final VoidCallback? onDeleteNote;
  final VoidCallback? onExport;
  final VoidCallback? onZenMode;
  final VoidCallback? onShareAesthetic;
  final VoidCallback? onReminder;
  final bool hasReminder;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final int wordCount;

  const EditorHeader({
    super.key,
    required this.onBack,
    this.isSaving = false,
    this.noteTitle = 'Editor',
    this.isPinned = false,
    this.isFavorite = false,
    this.isLocked = false,
    this.noteColor,
    this.onTogglePin,
    this.onToggleFavorite,
    this.onToggleLock,
    this.onPickColor,
    this.onDeleteNote,
    this.onExport,
    this.onZenMode,
    this.onShareAesthetic,
    this.onReminder,
    this.hasReminder = false,
    this.onUndo,
    this.onRedo,
    this.wordCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GlassContainer(
      borderRadius: BorderRadius.zero,
      blur: 24,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        bottom: 12,
        left: 12,
        right: 16,
      ),
      customBackground: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.85)
          : AppColors.lightSurface.withValues(alpha: 0.85),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassIconButton(
                  size: 34,
                  icon: Icon(Icons.arrow_back_ios_new, size: 16, color: onSurface),
                  onPressed: onBack,
                ),
                const SizedBox(width: 4),
                const AppEmblem(size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        noteTitle.isEmpty ? TextRegistry.get(TextKey.untitledNote) : noteTitle,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(onSurface, size: 14, weight: FontWeight.w600),
                      ),
                      Text(
                        isSaving
                            ? '...'
                            : (wordCount > 0
                                ? TextRegistry.get(TextKey.wordsCount, params: {'count': '$wordCount'})
                                : TextRegistry.get(TextKey.savedToDevice)),
                        style: AppTypography.caption(
                          isSaving ? primary : onSurfaceVar.withValues(alpha: 0.6),
                          size: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassIconButton(
                size: 34,
                icon: Icon(
                  Icons.undo,
                  size: 17,
                  color: onUndo != null ? onSurfaceVar : onSurfaceVar.withValues(alpha: 0.25),
                ),
                tooltip: 'Undo (Ctrl+Z)',
                onPressed: onUndo,
              ),
              const SizedBox(width: 4),
              GlassIconButton(
                size: 34,
                icon: Icon(
                  Icons.redo,
                  size: 17,
                  color: onRedo != null ? onSurfaceVar : onSurfaceVar.withValues(alpha: 0.25),
                ),
                tooltip: 'Redo (Ctrl+Y)',
                onPressed: onRedo,
              ),
              const SizedBox(width: 4),
              GlassIconButton(
                size: 34,
                icon: Icon(Icons.more_horiz, size: 20, color: onSurface),
                tooltip: 'Options',
                onPressed: () => EditorMoreMenuSheet.show(
                  context,
                  isPinned: isPinned,
                  isFavorite: isFavorite,
                  isLocked: isLocked,
                  hasReminder: hasReminder,
                  onTogglePin: onTogglePin,
                  onToggleFavorite: onToggleFavorite,
                  onToggleLock: onToggleLock,
                  onPickColor: onPickColor,
                  onZenMode: onZenMode,
                  onShareAesthetic: onShareAesthetic,
                  onReminder: onReminder,
                  onExport: onExport,
                  onDeleteNote: onDeleteNote,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerHigh.withValues(alpha: 0.6)
                      : AppColors.lightSurfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSaving ? Colors.amberAccent : primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSaving ? '...' : TextRegistry.get(TextKey.savedToDevice),
                      style: AppTypography.caption(onSurfaceVar, size: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
