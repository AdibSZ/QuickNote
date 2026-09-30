import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _restoreCtrl = TextEditingController();
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _restoreCtrl.dispose();
    super.dispose();
  }

  void _exportJson(List<Note> notes) {
    TactileFeedback.selection();
    final backupData = {
      'app': 'QuickNote',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notesCount': notes.length,
      'notes': notes.map((n) => n.toJson()).toList(),
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فایل پشتیبان JSON با موفقیت در کلیپ‌بورد کپی شد ✔️'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _restoreJson(NotesDirectoryCubit cubit) async {
    final text = _restoreCtrl.text.trim();
    if (text.isEmpty) return;

    TactileFeedback.medium();
    setState(() => _isRestoring = true);

    try {
      final dynamic decoded = jsonDecode(text);
      List<dynamic> notesRaw = [];
      if (decoded is Map && decoded.containsKey('notes')) {
        notesRaw = decoded['notes'] as List;
      } else if (decoded is List) {
        notesRaw = decoded;
      } else {
        throw const FormatException('ساختار فایل پشتیبان معتبر نیست.');
      }

      int restoredCount = 0;
      for (final item in notesRaw) {
        if (item is Map) {
          final note = Note.fromJson(Map<String, dynamic>.from(item));
          await cubit.createNewNote(title: note.title, category: note.category);
          restoredCount++;
        }
      }

      cubit.loadNotes();
      if (!mounted) return;
      setState(() => _isRestoring = false);
      _restoreCtrl.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$restoredCount یادداشت با موفقیت بازیابی شد! 🎉'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRestoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در بازیابی پشتیبان: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest;

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<NotesDirectoryCubit, NotesDirectoryState>(
        builder: (context, state) {
          final cubit = context.read<NotesDirectoryCubit>();
          final notes = state.allNotes;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_sync_outlined, color: primary, size: 22),
                      const SizedBox(width: 8),
                      Text('پشتیبان‌گیری و بازیابی محلی', style: AppTypography.title(onSurface, size: 16)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabCtrl,
                indicatorColor: primary,
                labelColor: primary,
                unselectedLabelColor: onSurfaceVar,
                tabs: const [
                  Tab(text: 'پشتیبان‌گیری (Export)'),
                  Tab(text: 'بازیابی (Restore)'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 210,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // Export Tab
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 44, color: primary.withValues(alpha: 0.8)),
                        const SizedBox(height: 10),
                        Text(
                          'تعداد کل یادداشت‌های آماده نسخه پشتیبان: ${notes.length}',
                          style: AppTypography.body(onSurface, size: 13, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'نسخه پشتیبان شامل متن، چک‌لیست‌ها، صداها و دسته‌بندی‌هاست.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(onSurfaceVar, size: 11),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _exportJson(notes),
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('کپی فایل پشتیبان JSON در کلیپ‌بورد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Restore Tab
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'کد یا متن فایل پشتیبان (JSON) را در کادر زیر وارد کنید:',
                          style: AppTypography.caption(onSurfaceVar, size: 11),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            controller: _restoreCtrl,
                            maxLines: 5,
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              hintText: '{\n  "notes": [...]\n}',
                              filled: true,
                              fillColor: isDark ? Colors.black26 : Colors.white70,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isRestoring ? null : () => _restoreJson(cubit),
                            icon: const Icon(Icons.file_upload_outlined, size: 18),
                            label: Text(_isRestoring ? 'در حال بازیابی...' : 'بازیابی یادداشت‌ها'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34C759),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
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
}
