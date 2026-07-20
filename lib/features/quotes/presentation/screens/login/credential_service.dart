import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;
import 'package:local_auth/local_auth.dart';

class CredentialService {
  static Future<({String email, bool biometricAvailable, bool hasSavedPassword})> loadSavedCredentials() async {

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';

    final isMobile = Platform.isAndroid || Platform.isIOS;
    final auth = LocalAuthentication();
    final hasBiometrics = await auth.canCheckBiometrics
        .timeout(const Duration(seconds: 5), onTimeout: () => false);
    final deviceSupported = isMobile && await auth.isDeviceSupported()
        .timeout(const Duration(seconds: 5), onTimeout: () => false);
    final biometricAvailable = hasBiometrics && deviceSupported;

    final hasSavedPassword = prefs.getBool('has_credentials') ?? false;



    return (
      email: savedEmail,
      biometricAvailable: biometricAvailable,
      hasSavedPassword: hasSavedPassword,
    );
  }

  static Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);

    if (rememberMe) {
      try {
        await const FlutterSecureStorage().write(
          key: 'saved_password',
          value: password,
        );
      } catch (_) {
        await prefs.setString('saved_password', password);
      }
      await prefs.setBool('has_credentials', true);
    } else {
      try {
        await const FlutterSecureStorage().delete(key: 'saved_password');
      } catch (_) {}
      await prefs.remove('saved_password');
      await prefs.remove('has_credentials');
    }
  }

  static Future<String?> loadSavedPassword() async {
    var savedPassword = await const FlutterSecureStorage()
        .read(key: 'saved_password');
    if (savedPassword == null || savedPassword.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      savedPassword = prefs.getString('saved_password');
    }
    return savedPassword;
  }

  static Future<String> loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email') ?? '';
  }
}
