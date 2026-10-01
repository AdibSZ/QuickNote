import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _pinKey = 'quicknote_security_pin';
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<String> getPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey) ?? '1234';
    } catch (_) {
      return '1234';
    }
  }

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  static Future<bool> verifyPin(String input) async {
    final current = await getPin();
    return input.trim() == current.trim();
  }

  static Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateBiometrics() async {
    try {
      final canCheck = await canUseBiometrics();
      if (!canCheck) return false;
      return await _auth.authenticate(
        localizedReason: 'QuickNote: Authenticate to access protected note',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      debugPrint('Biometrics PlatformException: $e');
      return false;
    } catch (e) {
      debugPrint('Biometrics error: $e');
      return false;
    }
  }
}
