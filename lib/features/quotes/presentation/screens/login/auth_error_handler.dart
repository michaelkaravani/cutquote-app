import 'package:firebase_auth/firebase_auth.dart';

String friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'user-not-found':
    case 'wrong-password':
      return 'שם המשתמש או הסיסמה שגויים';
    case 'invalid-email':
      return 'כתובת האימייל אינה תקינה';
    case 'user-disabled':
      return 'החשבון הושבת';
    case 'too-many-requests':
      return 'יותר מדי ניסיונות כושלים. אנא נסה מאוחר יותר';
    case 'network-request-failed':
      return 'בעיית רשת, אנא בדוק את החיבור שלך';
    case 'email-already-in-use':
      return 'כתובת האימייל כבר רשומה במערכת';
    case 'weak-password':
      return 'הסיסמה חייבת להכיל לפחות 6 תווים';
    default:
      return 'שגיאת התחברות: ${e.message}';
  }
}
