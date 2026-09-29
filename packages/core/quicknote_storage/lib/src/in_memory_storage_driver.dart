import 'storage_driver.dart';

/// In-Memory Storage Driver offering immediate zero-latency reads and writes.
/// Satisfies the "speed of light" in-memory first architecture rule.
class InMemoryStorageDriver implements StorageDriver {
  final Map<String, String> _cache = {};

  @override
  Future<void> init() async {}

  @override
  String? read(String key) => _cache[key];

  @override
  Future<void> write(String key, String value) async {
    _cache[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  @override
  List<String> getAllKeys() => _cache.keys.toList(growable: false);

  @override
  Future<void> clear() async {
    _cache.clear();
  }
}
