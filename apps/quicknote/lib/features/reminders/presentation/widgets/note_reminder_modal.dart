import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';

class NoteReminderModal extends StatefulWidget {
  final DateTime? currentReminder;
  final ValueChanged<DateTime?> onSave;

  const NoteReminderModal({
    super.key,
    required this.currentReminder,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required DateTime? currentReminder,
    required ValueChanged<DateTime?> onSave,
  }) {
    TactileFeedback.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteReminderModal(
        currentReminder: currentReminder,
        onSave: onSave,
      ),
    );
  }

  @override
  State<NoteReminderModal> createState() => _NoteReminderModalState();
}

class _NoteReminderModalState extends State<NoteReminderModal> {
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.currentReminder;
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y/$m/$d ساعت $hh:$mm';
  }

  void _setPreset(Duration offset, {int? exactHour}) {
    TactileFeedback.selection();
    final now = DateTime.now();
    DateTime target = now.add(offset);
    if (exactHour != null) {
      target = DateTime(target.year, target.month, target.day, exactHour, 0);
    }
    setState(() => _selectedTime = target);
  }

  Future<void> _pickCustomDateTime() async {
    TactileFeedback.selection();
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime ?? now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerHighest : AppColors.lightSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkHairlineBorder : AppColors.lightHairlineBorder,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.alarm_on_rounded, color: primary, size: 22),
                  const SizedBox(width: 8),
                  Text('تنظیم یادآور و هشدار', style: AppTypography.title(onSurface, size: 16)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Current Selected Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white60,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedTime != null ? primary.withValues(alpha: 0.5) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedTime != null ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                  color: _selectedTime != null ? primary : onSurfaceVar,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedTime != null ? _formatDateTime(_selectedTime!) : 'یادآوری تنظیم نشده است',
                    style: TextStyle(
                      color: _selectedTime != null ? onSurface : onSurfaceVar,
                      fontWeight: _selectedTime != null ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_selectedTime != null)
                  GestureDetector(
                    onTap: () {
                      TactileFeedback.light();
                      setState(() => _selectedTime = null);
                    },
                    child: const Icon(Icons.clear, size: 18, color: Colors.redAccent),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('زمان‌های پیشنهادی سریع:', style: AppTypography.caption(onSurfaceVar, size: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('۱ ساعت دیگر'),
                onPressed: () => _setPreset(const Duration(hours: 1)),
              ),
              ActionChip(
                label: const Text('امروز ۱۸:۰۰'),
                onPressed: () => _setPreset(Duration.zero, exactHour: 18),
              ),
              ActionChip(
                label: const Text('فردا ۰۹:۰۰'),
                onPressed: () => _setPreset(const Duration(days: 1), exactHour: 9),
              ),
              ActionChip(
                label: const Text('انتخاب دستی تاریخ و ساعت 📅'),
                onPressed: _pickCustomDateTime,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              if (widget.currentReminder != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      TactileFeedback.selection();
                      widget.onSave(null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('حذف یادآور'),
                  ),
                ),
              if (widget.currentReminder != null) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    TactileFeedback.success();
                    widget.onSave(_selectedTime);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ذخیره یادآور'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
