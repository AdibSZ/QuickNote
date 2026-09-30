import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/app_emblem.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../../core/ui_kit/glass_icon_button.dart';

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
                        noteTitle.isEmpty ? 'Untitled' : noteTitle,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(onSurface, size: 14, weight: FontWeight.w600),
                      ),
                      Text(
                        isSaving ? 'Saving...' : (wordCount > 0 ? '$wordCount words' : 'Saved'),
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
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: Row(
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
              if (onToggleFavorite != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 19,
                    color: isFavorite ? const Color(0xFFFFCC00) : onSurfaceVar,
                  ),
                  tooltip: isFavorite ? 'Favorited' : 'Favorite',
                  onPressed: onToggleFavorite,
                ),
                const SizedBox(width: 4),
              ],
              if (onTogglePin != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 17,
                    color: isPinned ? primary : onSurfaceVar,
                  ),
                  tooltip: isPinned ? 'Unpin' : 'Pin',
                  onPressed: onTogglePin,
                ),
                const SizedBox(width: 4),
              ],
              if (onPickColor != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    Icons.palette_outlined,
                    size: 17,
                    color: onSurfaceVar,
                  ),
                  tooltip: 'Color Tint',
                  onPressed: onPickColor,
                ),
                const SizedBox(width: 4),
              ],
              if (onToggleLock != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    isLocked ? Icons.lock : Icons.lock_open_outlined,
                    size: 17,
                    color: isLocked ? primary : onSurfaceVar,
                  ),
                  tooltip: isLocked ? 'Unlock Note' : 'Lock Note',
                  onPressed: onToggleLock,
                ),
                const SizedBox(width: 4),
              ],
              if (onZenMode != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(Icons.self_improvement, size: 18, color: onSurfaceVar),
                  tooltip: 'Zen Mode',
                  onPressed: onZenMode,
                ),
                const SizedBox(width: 4),
              ],
              if (onShareAesthetic != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: const Icon(Icons.auto_awesome_outlined, size: 17, color: Color(0xFFA855F7)),
                  tooltip: 'Share Card',
                  onPressed: onShareAesthetic,
                ),
                const SizedBox(width: 4),
              ],
              if (onReminder != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    hasReminder ? Icons.alarm_on_rounded : Icons.alarm_outlined,
                    size: 17,
                    color: hasReminder ? const Color(0xFF34C759) : onSurfaceVar,
                  ),
                  tooltip: 'Reminder',
                  onPressed: onReminder,
                ),
                const SizedBox(width: 4),
              ],
              if (onExport != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(Icons.ios_share_outlined, size: 17, color: onSurfaceVar),
                  tooltip: 'Share / Copy Markdown',
                  onPressed: onExport,
                ),
                const SizedBox(width: 4),
              ],
              if (onDeleteNote != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  tooltip: 'Delete Note',
                  onPressed: () => _confirmDelete(context),
                ),
                const SizedBox(width: 4),
              ],
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
                      isSaving ? 'Saving...' : 'Saved',
                      style: AppTypography.caption(onSurfaceVar, size: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteNote?.call();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
