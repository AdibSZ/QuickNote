import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class BackupRestoreModal extends StatefulWidget {
  const BackupRestoreModal({super.key});

  static void show(BuildContext context) {
    TactileFeedback.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<NotesDirectoryCubit>(),
        child: const BackupRestoreModal(),
      ),
    );
  }

  @override
  State<BackupRestoreModal> createState() => _BackupRestoreModalState();
}

class _BackupRestoreModalState extends State<BackupRestoreModal> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isExporting = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportZip(List<Note> notes) async {
    TactileFeedback.medium();
    setState(() => _isExporting = true);
    try {
      final archive = Archive();
      final notesBytes = utf8.encode(jsonEncode(notes.map((n) => n.toJson()).toList()));
      archive.addFile(ArchiveFile('notes.json', notesBytes.length, notesBytes));

      final manifestBytes = utf8.encode(jsonEncode({
        'app': 'QuickNote',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'notesCount': notes.length,
      }));
      archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

      final zipData = ZipEncoder().encode(archive);
      final fileName = 'quicknote_backup_${DateTime.now().millisecondsSinceEpoch}.zip';

      final output = await FilePicker.saveFile(
        dialogTitle: 'Save QuickNote Backup ZIP',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: Uint8List.fromList(zipData),
      );

      if (!mounted) return;
      setState(() => _isExporting = false);
      TactileFeedback.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(output != null ? 'Backup saved to $output! 📦' : 'Backup ZIP generated!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _pickAndRestoreZip(NotesDirectoryCubit cubit) async {
    TactileFeedback.medium();
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (res.isEmpty) return;

      final file = res.first;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;

      setState(() => _isRestoring = true);
      final archive = ZipDecoder().decodeBytes(bytes);
      ArchiveFile? notesFile;
      for (final f in archive.files) {
        if (f.name == 'notes.json' || f.name.endsWith('/notes.json')) {
          notesFile = f;
          break;
        }
      }

      if (notesFile == null) {
        throw Exception('Invalid QuickNote ZIP: missing notes.json file.');
      }

      final jsonStr = utf8.decode(notesFile.content as List<int>);
      final dynamic decoded = jsonDecode(jsonStr);

      List<dynamic> notesRaw = [];
      if (decoded is List) {
        notesRaw = decoded;
      } else if (decoded is Map && decoded.containsKey('notes')) {
        notesRaw = decoded['notes'] as List;
      }

      int count = 0;
      for (final item in notesRaw) {
        if (item is Map) {
          final note = Note.fromJson(Map<String, dynamic>.from(item));
          await cubit.createNewNote(title: note.title, category: note.category);
          count++;
        }
      }

      cubit.loadNotes();
      if (!mounted) return;
      setState(() => _isRestoring = false);
      Navigator.pop(context);
      TactileFeedback.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count notes restored successfully from ZIP! 🎉')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRestoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<NotesDirectoryCubit, NotesDirectoryState>(
        builder: (context, state) {
          final notes = state.allNotes;
          final cubit = context.read<NotesDirectoryCubit>();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_zip_outlined, color: primary, size: 24),
                      const SizedBox(width: 8),
                      Text('ZIP Backup & Restore', style: AppTypography.title(onSurface, size: 16)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabCtrl,
                indicatorColor: primary,
                labelColor: primary,
                unselectedLabelColor: onSurfaceVar,
                tabs: const [Tab(text: 'Export (.ZIP)'), Tab(text: 'Restore (.ZIP)')],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 190,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _tabView(
                      icon: Icons.archive_outlined,
                      color: primary,
                      title: '${notes.length} notes ready for ZIP packaging',
                      subtitle: 'Packages all blocks and metadata into a standalone .ZIP file.',
                      btnText: _isExporting ? 'Packaging ZIP...' : 'Download quicknote_backup.zip',
                      isLoading: _isExporting,
                      onPressed: () => _exportZip(notes),
                    ),
                    _tabView(
                      icon: Icons.unarchive_outlined,
                      color: const Color(0xFF34C759),
                      title: 'Upload .ZIP Backup Archive',
                      subtitle: 'Select quicknote_backup.zip from your device to restore notes.',
                      btnText: _isRestoring ? 'Restoring Archive...' : 'Select & Restore .ZIP',
                      isLoading: _isRestoring,
                      onPressed: () => _pickAndRestoreZip(cubit),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabView({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String btnText,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: color.withValues(alpha: 0.85)),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.body(Theme.of(context).brightness == Brightness.dark ? AppColors.darkOnSurface : AppColors.lightOnSurface, size: 13, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center, style: AppTypography.caption(Theme.of(context).brightness == Brightness.dark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant, size: 11)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: const Icon(Icons.touch_app_outlined, size: 18),
            label: Text(btnText),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
