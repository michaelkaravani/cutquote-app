import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'features/quotes/presentation/screens/login_screen.dart'; // ייבוא מסך ההתחברות החדש

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(const CutQuoteApp());
}

class CutQuoteApp extends StatelessWidget {
  const CutQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CutQuote',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF7F0), // רקע שמנת חם

        colorScheme: ColorScheme.light(
          primary: const Color(0xFF513222), // חום שוקולד כהה עמוק
          secondary: const Color(0xFFE88432), // כתום חמרה/טרקוטה
          surface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF513222),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE88432), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),

      home: const LoginScreen(), // נקודת הפתיחה משתנה למסך ההתחברות
    );
  }
}
