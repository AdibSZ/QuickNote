import 'dart:async';
import 'storage_driver.dart';

/// Coordinates an in-memory primary cache with asynchronous delta writes to disk.
/// Fulfills Section 1: "In-Memory First Persistence: Note reads and active edits
/// happen instantly in-memory. Disk writes must be non-blocking delta flushes."
class DeltaFlushPersister {
  final StorageDriver _primaryMemory;
  final StorageDriver? _underlyingDisk;
  final Duration _flushDebounce;

  Timer? _debounceTimer;
  final Map<String, String?> _pendingDeltas = {};
  bool _isFlushing = false;

  DeltaFlushPersister({
    required StorageDriver primaryMemory,
    StorageDriver? underlyingDisk,
    Duration flushDebounce = const Duration(milliseconds: 350),
  })  : _primaryMemory = primaryMemory,
        _underlyingDisk = underlyingDisk,
        _flushDebounce = flushDebounce;

  Future<void> init() async {
    await _primaryMemory.init();
    if (_underlyingDisk != null) {
      await _underlyingDisk!.init();
      final keys = _underlyingDisk!.getAllKeys();
      for (final key in keys) {
        final val = _underlyingDisk!.read(key);
        if (val != null) {
          await _primaryMemory.write(key, val);
        }
      }
    }
  }

  String? read(String key) => _primaryMemory.read(key);

  List<String> getAllKeys() => _primaryMemory.getAllKeys();

  void put(String key, String value) {
    _primaryMemory.write(key, value);
    if (_underlyingDisk != null) {
      _pendingDeltas[key] = value;
      _scheduleFlush();
    }
  }

  void remove(String key) {
    _primaryMemory.delete(key);
    if (_underlyingDisk != null) {
      _pendingDeltas[key] = null;
      _scheduleFlush();
    }
  }

  void _scheduleFlush() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_flushDebounce, _flushPendingDeltas);
  }

  Future<void> _flushPendingDeltas() async {
    if (_isFlushing || _pendingDeltas.isEmpty || _underlyingDisk == null) return;
    _isFlushing = true;

    final batch = Map<String, String?>.from(_pendingDeltas);
    _pendingDeltas.clear();

    try {
      for (final entry in batch.entries) {
        if (entry.value == null) {
          await _underlyingDisk!.delete(entry.key);
        } else {
          await _underlyingDisk!.write(entry.key, entry.value!);
        }
      }
    } catch (_) {
      // Delta write error can be retried or logged without failing UI
    } finally {
      _isFlushing = false;
      if (_pendingDeltas.isNotEmpty) {
        _scheduleFlush();
      }
    }
  }

  Future<void> forceFlush() async {
    _debounceTimer?.cancel();
    await _flushPendingDeltas();
  }
}
