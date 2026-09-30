import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknote_core/quicknote_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _prefKey = 'app_language_code';

  LocaleCubit() : super(const Locale('en')) {
    init();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'en';
      TextRegistry.setLocale(code);
      emit(Locale(code));
    } catch (_) {
      TextRegistry.setLocale('en');
      emit(const Locale('en'));
    }
  }

  Future<void> setLocale(String langCode) async {
    final normalized = langCode.toLowerCase().startsWith('fa') ? 'fa' : 'en';
    TextRegistry.setLocale(normalized);
    emit(Locale(normalized));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, normalized);
    } catch (_) {}
  }
}
