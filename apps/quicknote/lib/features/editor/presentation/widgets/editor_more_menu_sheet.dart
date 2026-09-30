import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class EditorMoreMenuSheet extends StatelessWidget {
  final bool isPinned;
  final bool isFavorite;
  final bool isLocked;
  final bool hasReminder;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onToggleLock;
  final VoidCallback? onPickColor;
  final VoidCallback? onZenMode;
  final VoidCallback? onShareAesthetic;
  final VoidCallback? onReminder;
  final VoidCallback? onExport;
  final VoidCallback? onDeleteNote;

  const EditorMoreMenuSheet({
    super.key,
    required this.isPinned,
    required this.isFavorite,
    required this.isLocked,
    required this.hasReminder,
    this.onTogglePin,
    this.onToggleFavorite,
    this.onToggleLock,
    this.onPickColor,
    this.onZenMode,
    this.onShareAesthetic,
    this.onReminder,
    this.onExport,
    this.onDeleteNote,
  });

  static void show(
    BuildContext context, {
    required bool isPinned,
    required bool isFavorite,
    required bool isLocked,
    required bool hasReminder,
    VoidCallback? onTogglePin,
    VoidCallback? onToggleFavorite,
    VoidCallback? onToggleLock,
    VoidCallback? onPickColor,
    VoidCallback? onZenMode,
    VoidCallback? onShareAesthetic,
    VoidCallback? onReminder,
    VoidCallback? onExport,
    VoidCallback? onDeleteNote,
  }) {
    TactileFeedback.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditorMoreMenuSheet(
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? const Color(0xFF1E1E24) : Colors.white;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: onSurfaceVar.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Note Options', style: AppTypography.title(onSurface, size: 16)),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Action grid / list
          if (onTogglePin != null)
            _tile(
              icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: isPinned ? primary : onSurface,
              title: isPinned ? 'Unpin Note' : 'Pin Note to Top',
              subtitle: isPinned ? 'Remove from pinned list' : 'Keep at the top of your directory',
              onTap: () {
                Navigator.pop(context);
                onTogglePin!();
              },
            ),
          if (onToggleFavorite != null)
            _tile(
              icon: isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? const Color(0xFFFFCC00) : onSurface,
              title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              subtitle: 'Quick access in favorite filters',
              onTap: () {
                Navigator.pop(context);
                onToggleFavorite!();
              },
            ),
          if (onPickColor != null)
            _tile(
              icon: Icons.palette_outlined,
              color: const Color(0xFF0A84FF),
              title: 'Note Color Tint',
              subtitle: 'Customize card and background accent hue',
              onTap: () {
                Navigator.pop(context);
                onPickColor!();
              },
            ),
          if (onToggleLock != null)
            _tile(
              icon: isLocked ? Icons.lock : Icons.lock_open_outlined,
              color: isLocked ? primary : onSurface,
              title: isLocked ? 'Unlock Note' : 'Lock Note',
              subtitle: isLocked ? 'Disable passcode security' : 'Protect with secure PIN code',
              onTap: () {
                Navigator.pop(context);
                onToggleLock!();
              },
            ),
          if (onZenMode != null)
            _tile(
              icon: Icons.self_improvement,
              color: const Color(0xFF30D158),
              title: 'Zen Focus Mode',
              subtitle: 'Distraction-free immersive typewriter writing',
              onTap: () {
                Navigator.pop(context);
                onZenMode!();
              },
            ),
          if (onShareAesthetic != null)
            _tile(
              icon: Icons.auto_awesome_outlined,
              color: const Color(0xFFA855F7),
              title: 'Share Aesthetic Card',
              subtitle: 'Generate aesthetic visual image card',
              onTap: () {
                Navigator.pop(context);
                onShareAesthetic!();
              },
            ),
          if (onReminder != null)
            _tile(
              icon: hasReminder ? Icons.alarm_on_rounded : Icons.alarm_outlined,
              color: hasReminder ? const Color(0xFF34C759) : onSurface,
              title: 'Reminder & Schedule',
              subtitle: hasReminder ? 'Reminder scheduled' : 'Set date and time reminder',
              onTap: () {
                Navigator.pop(context);
                onReminder!();
              },
            ),
          if (onExport != null)
            _tile(
              icon: Icons.ios_share_outlined,
              color: const Color(0xFFFF9F0A),
              title: 'Export / Copy Markdown',
              subtitle: 'Export note as Markdown or copy plain text',
              onTap: () {
                Navigator.pop(context);
                onExport!();
              },
            ),
          if (onDeleteNote != null) ...[
            const Divider(height: 16),
            _tile(
              icon: Icons.delete_outline,
              color: Colors.redAccent,
              title: 'Delete Note',
              subtitle: 'Move note to trash or delete permanently',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: isDestructive ? Colors.redAccent : null,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: () {
        TactileFeedback.selection();
        onTap();
      },
    );
  }
}
