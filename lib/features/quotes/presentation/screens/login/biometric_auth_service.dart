import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'credential_service.dart';

class BiometricAuthResult {
  final String email;
  final String password;
  final String? error;

  BiometricAuthResult({
    required this.email,
    required this.password,
    this.error,
  });

  bool get isSuccess => error == null;
}

class BiometricAuthService {
  static Future<BiometricAuthResult> authenticate() async {
    try {
      final auth = LocalAuthentication();
      final authenticated = await auth.authenticate(
        localizedReason: 'התחברות מהירה להצעת מחיר',
        authMessages: [],
      );

      if (!authenticated) {
        return BiometricAuthResult(
          email: '',
          password: '',
          error: 'טביעת האצבע לא זוהתה',
        );
      }

      final savedPassword = await CredentialService.loadSavedPassword();

      if (savedPassword == null || savedPassword.isEmpty) {
        return BiometricAuthResult(
          email: '',
          password: '',
          error: 'לא נמצאו פרטי התחברות שמורים',
        );
      }

      final email = await CredentialService.loadSavedEmail();

      return BiometricAuthResult(email: email, password: savedPassword);
    } on PlatformException catch (e) {
      String message;
      switch (e.code) {
        case 'NotAvailable':
        case 'BiometricNotAvailable':
          message = 'טביעת אצבע לא זמינה במכשיר זה';
          break;
        case 'NotEnrolled':
          message = 'לא הוגדרה טביעת אצבע במכשיר';
          break;
        case 'LockedOut':
        case 'PermanentlyLocked':
          message = 'טביעת האצבע ננעלה, אנא השתמש בסיסמה';
          break;
        default:
          message = 'טביעת אצבע: ${e.code} - ${e.message}';
      }
      return BiometricAuthResult(email: '', password: '', error: message);
    } catch (e) {
      return BiometricAuthResult(email: '', password: '', error: 'שגיאה: $e');
    }
  }
}
