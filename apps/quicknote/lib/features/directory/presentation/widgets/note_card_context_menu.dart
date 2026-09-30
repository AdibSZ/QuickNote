import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../editor/presentation/widgets/note_color_picker_modal.dart';
import '../../../reminders/presentation/widgets/note_reminder_modal.dart';
import '../../../security/presentation/widgets/note_security_modal.dart';
import '../../../sharing/presentation/widgets/aesthetic_card_modal.dart';

class NoteCardContextMenu {
  static void show({
    required BuildContext context,
    required Note note,
    required VoidCallback onTogglePin,
    VoidCallback? onToggleFavorite,
    ValueChanged<String?>? onColorSelected,
    VoidCallback? onDuplicate,
    required VoidCallback onDelete,
    VoidCallback? onToggleLock,
    ValueChanged<DateTime?>? onSetReminder,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tile(ctx, note.isPinned ? Icons.push_pin_outlined : Icons.push_pin, note.isPinned ? 'Unpin' : 'Pin to Top', onTogglePin),
              if (onToggleFavorite != null)
                _tile(ctx, note.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
                    note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites', onToggleFavorite,
                    color: const Color(0xFFFFCC00)),
              _tile(ctx, Icons.share_outlined, 'Share as Aesthetic Card',
                  () => AestheticCardModal.show(context, note), color: const Color(0xFFA855F7)),
              if (onSetReminder != null)
                _tile(ctx, Icons.alarm_rounded, note.reminderAt != null ? 'Edit Reminder' : 'Set Reminder',
                    () => NoteReminderModal.show(context, currentReminder: note.reminderAt, onSave: onSetReminder),
                    color: const Color(0xFF34C759)),
              if (onToggleLock != null)
                _tile(ctx, note.isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                    note.isLocked ? 'Unlock Note' : 'Lock Note (Security)', () {
                  if (note.isLocked) {
                    NoteSecurityModal.show(context, noteTitle: note.title, onAuthenticated: onToggleLock);
                  } else {
                    onToggleLock();
                  }
                }),
              if (onColorSelected != null)
                _tile(ctx, Icons.palette_outlined, 'Note Tint Theme',
                    () => NoteColorPickerModal.show(context, currentColor: note.color, onColorSelected: onColorSelected)),
              if (onDuplicate != null)
                _tile(ctx, Icons.copy_outlined, 'Duplicate Note', onDuplicate),
              _tile(ctx, Icons.delete_outline, 'Delete Note', onDelete, color: Colors.redAccent),
            ],
          ),
        );
      },
    );
  }

  static Widget _tile(BuildContext ctx, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
    );
  }
}
