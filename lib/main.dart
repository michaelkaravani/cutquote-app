import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/app_theme.dart';
import 'core/theme_notifier.dart' show themeNotifier;
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
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CutQuote Pro',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeNotifier.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE88432)),
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data!.emailVerified) {
                return const HomeScreen();
              }

              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
