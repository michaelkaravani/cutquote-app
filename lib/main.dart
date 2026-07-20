import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/theme_notifier.dart' show themeNotifier;
import 'core/pdf_template_notifier.dart';
import 'core/error_boundary.dart';
import 'features/quotes/presentation/screens/home_screen.dart';
import 'features/quotes/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, stack) {
    // This is a rare case where Firebase initialization itself fails.
    // We can't log to Crashlytics, so we just print to console.
    debugPrint('Firebase Initialization Error: $e\n$stack');
  }

  runApp(const MyApp());
}

/// Centralized error logging for non-fatal errors
void _logError(String context, Object error, StackTrace? stack) {
  debugPrint('═══════════════════════════════════════');
  debugPrint('NON-FATAL ERROR: $context');
  debugPrint('ERROR: $error');
  if (stack != null) {
    debugPrint('STACK TRACE:\n$stack');
  }
  debugPrint('═══════════════════════════════════════');

  // Send non-fatal errors to Crashlytics
  FirebaseCrashlytics.instance.recordError(error, stack, reason: context);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initializingUid;
  Future<void>? _templateInitialization;

  Future<void> _initializeTemplate(String uid) {
    if (_initializingUid != uid || _templateInitialization == null) {
      _initializingUid = uid;
      _templateInitialization = pdfTemplateNotifier.initialize(uid);
    }
    return _templateInitialization!;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CutQuote Pro',
          theme: buildLightTheme(style: themeNotifier.themeStyle),
          darkTheme: buildDarkTheme(style: themeNotifier.themeStyle),
          themeMode: themeNotifier.themeMode,
          locale: const Locale('he', 'IL'),
          supportedLocales: const [Locale('he', 'IL')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ErrorBoundary(
            onError: (details) {
              _logError('Widget Error', details.exception, details.stack);
            },
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Handle connection errors
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'שגיאת חיבור',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'לא ניתן להתחבר לשרת. בדוק את חיבור האינטרנט.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    body: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.data?.emailVerified == true) {
                  return FutureBuilder<void>(
                    future: _initializeTemplate(snapshot.data!.uid),
                    builder: (context, templateSnapshot) {
                      if (templateSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Scaffold(
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          body: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const HomeScreen();
                    },
                  );
                }

                return const LoginScreen();
              },
            ),
          ),
        );
      },
    );
  }
}
