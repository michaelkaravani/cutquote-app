import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'features/quotes/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(const CutQuoteApp());
}

class CutQuoteApp extends StatelessWidget {
  const CutQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
