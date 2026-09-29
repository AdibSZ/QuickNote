import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/text_direction_helper.dart';
import '../../../../../core/ui_kit/glass_container.dart';
import '../../../../../core/ui_kit/tactile_feedback.dart';
import 'audio_control_buttons.dart';
import 'audio_memo_header.dart';
import 'audio_service.dart';
import 'audio_waveform_widget.dart';

class AudioMemoBlockWidget extends StatefulWidget {
  final NoteBlock block;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onTranscriptChanged;
  final VoidCallback onDelete;

  const AudioMemoBlockWidget({
    super.key,
    required this.block,
    required this.onTitleChanged,
    required this.onTranscriptChanged,
    required this.onDelete,
  });

  @override
  State<AudioMemoBlockWidget> createState() => _AudioMemoBlockWidgetState();
}

class _AudioMemoBlockWidgetState extends State<AudioMemoBlockWidget> {
  late TextEditingController _titleController;
  late TextEditingController _transcriptController;
  final AudioService _audioService = AudioService();

  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordSeconds = 0;
  int _playSeconds = 0;
  int _totalSeconds = 10;
  Timer? _timer;
  List<double> _dynamicAmps = List.filled(30, 0.35);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.block.content.isEmpty ? 'Voice Note' : widget.block.content,
    );
    final transcript = widget.block.metadata['transcript'] as String? ?? '';
    _transcriptController = TextEditingController(text: transcript);

    final durSec = widget.block.metadata['durationSeconds'] as int?;
    if (durSec != null && durSec > 0) {
      _totalSeconds = durSec;
    }

    final audioPath = widget.block.metadata['audioPath'] as String?;
    _audioService.init(existingPath: audioPath);

    _audioService.onAmplitude = (amp) {
      if (!mounted || !_isRecording) return;
      setState(() => _dynamicAmps = List.generate(30, (i) {
        final seed = ((i * 7 + _recordSeconds * 13) % 10) / 10.0;
        return (amp * 0.7 + seed * 0.3).clamp(0.15, 1.0);
      }));
    };

    _audioService.onPosition = (pos) {
      if (!mounted) return;
      setState(() {
        _playSeconds = pos.inSeconds;
        if (_playSeconds > _totalSeconds) _totalSeconds = _playSeconds;
      });
    };

    _audioService.onPlayStateChanged = (playing) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playing;
        if (!playing && _playSeconds >= _totalSeconds) _playSeconds = 0;
      });
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    _titleController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleRecord() async {
    TactileFeedback.medium();
    if (_isRecording) {
      _timer?.cancel();
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _totalSeconds = _recordSeconds > 0 ? _recordSeconds : 5;
        _recordSeconds = 0;
        _dynamicAmps = List.filled(30, 0.35);
      });
      widget.block.metadata['durationSeconds'] = _totalSeconds;
      if (path != null) {
        widget.block.metadata['audioPath'] = path;
      }
    } else {
      if (_isPlaying) {
        await _audioService.stopPlayback();
      }
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _recordSeconds++);
      });
      await _audioService.startRecording();
    }
  }

  Future<void> _togglePlay() async {
    TactileFeedback.light();
    if (_isRecording) return;
    if (_isPlaying) {
      await _audioService.pausePlayback();
    } else {
      await _audioService.startPlayback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final onPrimary = isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;

    final transcriptRtl = isRtlText(_transcriptController.text);
    final displayTime = _isRecording
        ? _formatTime(_recordSeconds)
        : '${_formatTime(_playSeconds)} / ${_formatTime(_totalSeconds)}';

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(16),
      customBackground: isDark
          ? AppColors.darkSurfaceContainerHigh.withValues(alpha: 0.5)
          : AppColors.lightSurfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AudioMemoHeader(
            titleController: _titleController,
            isRecording: _isRecording,
            displayTime: displayTime,
            primary: primary,
            onSurface: onSurface,
            onSurfaceVar: onSurfaceVar,
            isDark: isDark,
            onTitleChanged: (val) {
              setState(() {});
              widget.onTitleChanged(val);
            },
            onDelete: widget.onDelete,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AudioControlButtons(
                isRecording: _isRecording,
                isPlaying: _isPlaying,
                onTogglePlay: _togglePlay,
                onToggleRecord: _toggleRecord,
                primary: primary,
                onPrimary: onPrimary,
                onSurfaceVar: onSurfaceVar,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AudioWaveformWidget(
                  isRecording: _isRecording,
                  isPlaying: _isPlaying,
                  playSeconds: _playSeconds,
                  totalSeconds: _totalSeconds,
                  recordSeconds: _recordSeconds,
                  dynamicAmplitudes: _isRecording ? _dynamicAmps : null,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _transcriptController,
            onChanged: (val) {
              setState(() {});
              widget.onTranscriptChanged(val);
            },
            textDirection: transcriptRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: transcriptRtl ? TextAlign.right : TextAlign.left,
            style: AppTypography.caption(onSurfaceVar, size: 11),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Voice notes or transcript...',
              hintStyle: AppTypography.caption(onSurfaceVar.withValues(alpha: 0.4), size: 11),
            ),
          ),
        ],
      ),
    );
  }
}
