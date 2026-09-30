import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import '../../backup/presentation/widgets/backup_restore_modal.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<NotesDirectoryCubit>()),
          BlocProvider.value(value: context.read<ThemeCubit>()),
          BlocProvider.value(value: context.read<LocaleCubit>()),
        ],
        child: const SettingsModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final bg = isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: BlocBuilder<NotesDirectoryCubit, NotesDirectoryState>(
        builder: (context, state) {
          final totalNotes = state.allNotes.length;
          final totalWords = state.allNotes.fold<int>(0, (sum, n) => sum + n.wordCount);

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(TextRegistry.get(TextKey.settingsTitle), style: AppTypography.title(onSurface, size: 18)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(TextRegistry.get(TextKey.appearance), style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) => SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(value: ThemeMode.dark, label: Text(TextRegistry.get(TextKey.darkMode)), icon: const Icon(Icons.dark_mode_outlined, size: 14)),
                      ButtonSegment(value: ThemeMode.light, label: Text(TextRegistry.get(TextKey.lightMode)), icon: const Icon(Icons.light_mode_outlined, size: 14)),
                    ],
                    selected: {mode},
                    onSelectionChanged: (set) {
                      TactileFeedback.click();
                      context.read<ThemeCubit>().setTheme(set.first);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(TextRegistry.get(TextKey.language), style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                BlocBuilder<LocaleCubit, Locale>(
                  builder: (context, locale) => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('English'), icon: Icon(Icons.language, size: 14)),
                      ButtonSegment(value: 'fa', label: Text('فارسی (Persian)'), icon: Icon(Icons.translate, size: 14)),
                    ],
                    selected: {locale.languageCode},
                    onSelectionChanged: (set) {
                      TactileFeedback.selection();
                      context.read<LocaleCubit>().setLocale(set.first);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(TextRegistry.get(TextKey.storageStats), style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatTile(label: TextRegistry.get(TextKey.totalNotes), value: '$totalNotes', color: onSurface),
                      _StatTile(label: TextRegistry.get(TextKey.totalWords), value: '$totalWords', color: onSurface),
                      _StatTile(label: TextRegistry.get(TextKey.storageMode), value: 'Memory+WAL', color: onSurface),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(TextRegistry.get(TextKey.backupExport), style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.archive_outlined, color: Color(0xFF0A84FF), size: 20),
                  title: const Text('Local Backup & Restore (.zip)'),
                  subtitle: const Text('Export complete notes archive or restore from .zip'),
                  onTap: () {
                    Navigator.pop(context);
                    BackupRestoreModal.show(context);
                  },
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.file_download_outlined, size: 20),
                  title: const Text('Copy All Notes as Markdown'),
                  onTap: () => _exportAllMarkdown(context, state.allNotes),
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.data_object, size: 20),
                  title: const Text('Copy All Notes as JSON'),
                  onTap: () => _exportAllJson(context, state.allNotes),
                ),
                const Divider(height: 24),
                Text(TextRegistry.get(TextKey.helpProductivity), style: AppTypography.caption(onSurfaceVar, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.keyboard_outlined, size: 20),
                  title: Text(TextRegistry.get(TextKey.keyboardShortcuts)),
                  onTap: () => _showShortcutsDialog(context),
                ),
                const Divider(height: 24),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                  title: Text(TextRegistry.get(TextKey.clearAllNotes), style: const TextStyle(color: Colors.redAccent)),
                  onTap: () => _confirmClearAll(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _exportAllMarkdown(BuildContext context, List<Note> notes) {
    TactileFeedback.light();
    final md = notes.map((n) => n.toMarkdown()).join('\n\n---\n\n');
    Clipboard.setData(ClipboardData(text: md));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notes copied to clipboard as Markdown!')),
    );
  }

  void _exportAllJson(BuildContext context, List<Note> notes) {
    TactileFeedback.light();
    final raw = jsonEncode(notes.map((n) => n.toJson()).toList());
    Clipboard.setData(ClipboardData(text: raw));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notes JSON copied to clipboard!')),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notes?'),
        content: const Text('This will delete all your notes from local storage. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NotesDirectoryCubit>().clearAllNotes();
              Navigator.pop(context);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showShortcutsDialog(BuildContext context) {
    TactileFeedback.light();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(TextRegistry.get(TextKey.keyboardShortcuts)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShortcutRow(keys: 'Ctrl + Z', description: 'Undo last edit'),
            SizedBox(height: 8),
            _ShortcutRow(keys: 'Ctrl + Y', description: 'Redo edit'),
            SizedBox(height: 8),
            _ShortcutRow(keys: 'Enter', description: 'Add next task in checklist'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final String keys;
  final String description;

  const _ShortcutRow({required this.keys, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(keys, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Text(description, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.title(color, size: 14, weight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption(AppColors.darkOutline, size: 10)),
      ],
    );
  }
}
