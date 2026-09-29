import 'package:flutter/material.dart';
import 'package:quicknote_core/quicknote_core.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/app_emblem.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../../core/ui_kit/glass_icon_button.dart';

class DirectoryHeader extends StatelessWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onNewNotePressed;
  final VoidCallback? onSortPressed;

  const DirectoryHeader({
    super.key,
    this.onSettingsPressed,
    this.onNewNotePressed,
    this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return GlassContainer(
      borderRadius: BorderRadius.zero,
      blur: 24,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      customBackground: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.82)
          : AppColors.lightSurface.withValues(alpha: 0.85),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppEmblem(size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    TextRegistry.get(TextKey.appName),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(onSurface, size: 15, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.lightSurfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    TextRegistry.get(TextKey.directoryTitle),
                    style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onSortPressed != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    Icons.swap_vert_rounded,
                    size: 19,
                    color: onSurfaceVar,
                  ),
                  tooltip: 'Sort Notes',
                  onPressed: onSortPressed,
                ),
                const SizedBox(width: 6),
              ],
              if (onSettingsPressed != null) ...[
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: onSurfaceVar,
                  ),
                  tooltip: TextRegistry.get(TextKey.settingsTitle),
                  onPressed: onSettingsPressed,
                ),
                const SizedBox(width: 6),
              ],
              if (onNewNotePressed != null) ...[
                const SizedBox(width: 4),
                GlassIconButton(
                  size: 34,
                  icon: Icon(
                    Icons.add,
                    size: 20,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                  tooltip: TextRegistry.get(TextKey.newNoteButton),
                  onPressed: onNewNotePressed,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
