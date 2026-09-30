import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import 'blocks/doodle_canvas_modal.dart';

class DockedBottomBar extends StatefulWidget {
  final VoidCallback onAddBlock;
  final ValueChanged<int> onVoiceRecorded;
  final VoidCallback onAddChecklist;
  final VoidCallback onInsertDate;
  final ValueChanged<String> onAddImage;
  final ValueChanged<String> onAddDoodle;
  final VoidCallback onAddCallout;
  final VoidCallback onInsertCode;
  final VoidCallback onAddQuote;
  final VoidCallback onFormatText;

  const DockedBottomBar({
    super.key,
    required this.onAddBlock,
    required this.onVoiceRecorded,
    required this.onAddChecklist,
    required this.onInsertDate,
    required this.onAddImage,
    required this.onAddDoodle,
    required this.onAddCallout,
    required this.onInsertCode,
    required this.onAddQuote,
    required this.onFormatText,
  });

  @override
  State<DockedBottomBar> createState() => _DockedBottomBarState();
}

class _DockedBottomBarState extends State<DockedBottomBar> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void dispose() {
    _recordTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  void _startRecording() {
    TactileFeedback.heavy();
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _anim.repeat(reverse: true);
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordSeconds++);
    });
  }

  void _stopRecording() {
    TactileFeedback.success();
    final d = _recordSeconds;
    _resetRecording();
    widget.onVoiceRecorded(d > 0 ? d : 1);
  }

  void _resetRecording() {
    _recordTimer?.cancel();
    _anim.stop();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  Future<void> _pickImage() async {
    TactileFeedback.selection();
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (img != null) widget.onAddImage(img.path);
    } catch (_) {}
  }

  String _formatTime(int sec) {
    return '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad + 10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isRecording ? _buildRecordingBar() : _buildNormalBar(isDark),
      ),
    );
  }

  Widget _buildRecordingBar() {
    return ClipRRect(
      key: const ValueKey('recording_bar'),
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFDC2626).withValues(alpha: 0.85),
                const Color(0xFF991B1B).withValues(alpha: 0.75),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (context, child) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5 + (_anim.value * 0.5)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(_recordSeconds),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _anim,
                builder: (context, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(7, (i) {
                    final factor = ((math.sin(_anim.value * 2 * math.pi + (i * 0.9)) + 1) / 2).clamp(0.2, 1.0);
                    return Container(
                      width: 3.5,
                      height: 8 + (18 * factor),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                tooltip: 'Discard',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: () {
                  TactileFeedback.medium();
                  _resetRecording();
                },
              ),
              const SizedBox(width: 6),
              Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.check, color: Color(0xFFDC2626), size: 18),
                  tooltip: 'Finish',
                  padding: const EdgeInsets.all(7),
                  constraints: const BoxConstraints(),
                  onPressed: _stopRecording,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalBar(bool isDark) {
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    return ClipRRect(
      key: const ValueKey('normal_bar'),
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF16161B).withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.0,
            ),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _btn(Icons.add_circle_outline, 'Add Block', onSurface, widget.onAddBlock),
              _btn(Icons.check_box_outlined, 'Checklist', const Color(0xFF38BDF8), widget.onAddChecklist),
              _btn(Icons.image_outlined, 'Add Image', const Color(0xFF4ADE80), _pickImage),
              _btn(Icons.draw_outlined, 'Doodle', const Color(0xFFF472B6), () {
                TactileFeedback.medium();
                DoodleCanvasModal.show(context, onSave: widget.onAddDoodle);
              }),
              _btn(Icons.mic_none, 'Record Audio', const Color(0xFFF87171), _startRecording),
              _btn(Icons.today_outlined, 'Today Date', const Color(0xFFFBBF24), widget.onInsertDate),
              _btn(Icons.lightbulb_outline, 'Callout', const Color(0xFFA78BFA), widget.onAddCallout),
              _btn(Icons.data_object, 'Code', const Color(0xFF818CF8), widget.onInsertCode),
              _btn(Icons.format_quote_rounded, 'Quote', const Color(0xFFE879F9), widget.onAddQuote),
              _btn(Icons.format_size, 'Format', onSurface, widget.onFormatText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              TactileFeedback.selection();
              onTap();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Icon(icon, size: 21, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
