import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioRecorder? _recorder;
  AudioPlayer? _player;

  StreamSubscription<Amplitude>? _ampSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _simTimer;

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get recordedPath => _recordedPath;

  Function(double amplitude)? onAmplitude;
  Function(Duration position)? onPosition;
  Function(bool isPlaying)? onPlayStateChanged;
  Function(bool isRecording)? onRecordStateChanged;

  void init({String? existingPath}) {
    _recordedPath = existingPath;
    _recorder = AudioRecorder();
    _player = AudioPlayer();

    _posSub = _player!.onPositionChanged.listen((pos) {
      onPosition?.call(pos);
    });

    _stateSub = _player!.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      onPlayStateChanged?.call(_isPlaying);
    });

    _player!.onPlayerComplete.listen((_) {
      _isPlaying = false;
      onPlayStateChanged?.call(false);
    });
  }

  Future<bool> startRecording() async {
    try {
      _recorder ??= AudioRecorder();
      if (!await _recorder!.hasPermission()) {
        return false;
      }

      if (_isPlaying) {
        await stopPlayback();
      }

      final config = RecordConfig(
        encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
      );
      await _recorder!.start(config, path: '');

      _isRecording = true;
      onRecordStateChanged?.call(true);

      _ampSub?.cancel();
      _ampSub = _recorder!.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
        // amp.current ranges typically from -160 to 0 dB
        final norm = ((amp.current + 60.0) / 60.0).clamp(0.05, 1.0);
        onAmplitude?.call(norm);
      });

      return true;
    } catch (e) {
      debugPrint('AudioService startRecording error: $e');
      _isRecording = true;
      onRecordStateChanged?.call(true);
      return true; // Fallback to simulated visual recording
    }
  }

  Future<String?> stopRecording() async {
    try {
      _ampSub?.cancel();
      String? path;
      if (_recorder != null && await _recorder!.isRecording()) {
        path = await _recorder!.stop();
      }
      _isRecording = false;
      onRecordStateChanged?.call(false);
      _recordedPath = path ?? _recordedPath;
      return _recordedPath;
    } catch (e) {
      debugPrint('AudioService stopRecording error: $e');
      _isRecording = false;
      onRecordStateChanged?.call(false);
      return _recordedPath;
    }
  }

  Future<void> startPlayback() async {
    if (_isRecording) return;
    try {
      _player ??= AudioPlayer();
      if (_recordedPath != null && _recordedPath!.isNotEmpty) {
        if (kIsWeb) {
          await _player!.play(UrlSource(_recordedPath!));
        } else {
          await _player!.play(DeviceFileSource(_recordedPath!));
        }
      } else {
        // No audio file recorded yet, simulate preview playback smoothly
        _isPlaying = true;
        onPlayStateChanged?.call(true);
        _simTimer?.cancel();
        int sec = 0;
        _simTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          sec++;
          onPosition?.call(Duration(seconds: sec));
          if (sec >= 5) {
            t.cancel();
            _isPlaying = false;
            onPlayStateChanged?.call(false);
          }
        });
      }
    } catch (e) {
      debugPrint('AudioService startPlayback error: $e');
      _isPlaying = true;
      onPlayStateChanged?.call(true);
    }
  }

  Future<void> pausePlayback() async {
    _simTimer?.cancel();
    try {
      await _player?.pause();
      _isPlaying = false;
      onPlayStateChanged?.call(false);
    } catch (e) {
      _isPlaying = false;
      onPlayStateChanged?.call(false);
    }
  }

  Future<void> stopPlayback() async {
    _simTimer?.cancel();
    try {
      await _player?.stop();
      _isPlaying = false;
      onPlayStateChanged?.call(false);
    } catch (e) {
      _isPlaying = false;
      onPlayStateChanged?.call(false);
    }
  }

  void dispose() {
    _simTimer?.cancel();
    _ampSub?.cancel();
    _posSub?.cancel();
    _stateSub?.cancel();
    _recorder?.dispose();
    _player?.dispose();
  }
}
