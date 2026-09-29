import 'package:quicknote_storage/quicknote_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences implementation of StorageDriver for persistent disk backing.
class SharedPreferencesStorageDriver implements StorageDriver {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  String? read(String key) => _prefs?.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs?.remove(key);
  }

  @override
  List<String> getAllKeys() => _prefs?.getKeys().toList() ?? [];

  @override
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
