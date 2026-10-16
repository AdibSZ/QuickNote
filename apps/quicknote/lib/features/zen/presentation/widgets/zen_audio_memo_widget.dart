import 'package:flutter/material.dart';
import 'package:quicknote_notes/quicknote_notes.dart';
import '../../../../core/theme/text_direction_helper.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import '../../../editor/presentation/widgets/blocks/audio_service.dart';

class ZenAudioMemoWidget extends StatefulWidget {
  final NoteBlock block;
  final Color fg;
  final double fontSize;

  const ZenAudioMemoWidget({
    super.key,
    required this.block,
    required this.fg,
    required this.fontSize,
  });

  @override
  State<ZenAudioMemoWidget> createState() => _ZenAudioMemoWidgetState();
}

class _ZenAudioMemoWidgetState extends State<ZenAudioMemoWidget> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  int _positionSeconds = 0;
  int _totalSeconds = 10;

  @override
  void initState() {
    super.initState();
    final dur = widget.block.metadata['durationSeconds'] as int?;
    if (dur != null && dur > 0) {
      _totalSeconds = dur;
    }
    final audioPath = widget.block.metadata['audioPath'] as String?;
    _audioService.init(existingPath: audioPath);

    _audioService.onPlayStateChanged = (playing) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playing;
        if (!playing && _positionSeconds >= _totalSeconds) {
          _positionSeconds = 0;
        }
      });
    };

    _audioService.onPosition = (pos) {
      if (!mounted) return;
      setState(() {
        _positionSeconds = pos.inSeconds;
        if (_positionSeconds > _totalSeconds) {
          _totalSeconds = _positionSeconds;
        }
      });
    };
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _togglePlay() {
    TactileFeedback.light();
    if (_isPlaying) {
      _audioService.pausePlayback();
    } else {
      _audioService.startPlayback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.fg;
    final rawContent = widget.block.content;
    final content = rawContent.isEmpty ? 'Voice Note' : rawContent;
    final isRtl = isRtlText(content);
    final dir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final align = isRtl ? TextAlign.right : TextAlign.left;

    final progress = _totalSeconds > 0
        ? (_positionSeconds / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: fg.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: dir,
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: fg,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      textDirection: dir,
                      textAlign: align,
                      style: TextStyle(
                        color: fg,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatTime(_positionSeconds)} / ${_formatTime(_totalSeconds)}',
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.graphic_eq_rounded,
                color: _isPlaying ? fg : fg.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: fg.withValues(alpha: 0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(fg.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
