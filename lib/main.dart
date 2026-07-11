import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ה-Imports המתוקנים והמדויקים לפי מבנה התיקיות האמיתי שלך:
import 'features/quotes/presentation/screens/home_screen.dart';
import 'features/quotes/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CutQuote Pro',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF7F0),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFFAF7F0),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFE88432)),
              ),
            );
          }

          // אם המשתמש מחובר והמייל שלו מאומת
          if (snapshot.hasData && snapshot.data!.emailVerified) {
            return const HomeScreen();
          }

          // אחרת - תמיד למסך ההתחברות
          return const LoginScreen();
        },
      ),
    );
  }
}
