/// Abstract contract for storage engines.
/// Keeps low-level storage swappable (In-memory, SQLite WAL, Hive, LocalStorage).
abstract class StorageDriver {
  Future<void> init();
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  List<String> getAllKeys();
  Future<void> clear();
}
