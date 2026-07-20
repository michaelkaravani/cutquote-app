import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/navigation.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/core/theme_notifier.dart';
import 'package:cutquote/core/app_theme.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/theme_picker.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/pdf_template_chooser.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/profile_details_card.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/vat_settings_card.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/pdf_settings_card.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/logout_dialog.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _email => FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final profileData = await FirestoreService.loadProfile(_uid);
      if (!mounted) return;
      setState(() {
        _profile = profileData ?? {};
        // Ensure email is always populated from auth
        _profile['email'] = _email;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בטעינת הפרופיל: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await showLogoutConfirmation(context);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleSendPasswordReset() async {
    if (_email.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('קישור לאיפוס סיסמה נשלח לכתובת:\n$_email'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה: ${e.message} (${e.code})'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'ברירת מחדל של המערכת';
      case ThemeMode.light: return 'מצב בהיר';
      case ThemeMode.dark: return 'מצב כהה';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('פרופיל משתמש')),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('פרופיל והגדרות'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.business_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        // Dummy listenable for force-rebuilding when profile details change
                        ValueNotifier(_profile['businessName']), 
                      ]),
                      builder: (context, _) {
                         return Text(
                          _profile['businessName']?.isNotEmpty == true
                              ? _profile['businessName']
                              : 'שם העסק שלך',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      }
                    ),
                    Text(
                      'מנהל מערכת',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ProfileDetailsCard(initialProfile: _profile),
              const SizedBox(height: 24),
              VatSettingsCard(initialProfile: _profile),
              const SizedBox(height: 24),
              PdfSettingsCard(initialProfile: _profile),
              const SizedBox(height: 24),
              Card(
                surfaceTintColor: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'ערכת נושא',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: ListenableBuilder(
                    listenable: themeNotifier,
                    builder: (context, _) => Text(
                      '${themeNotifier.themeStyle.label} • ${_themeModeLabel(themeNotifier.themeMode)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onTap: () => ThemePicker.show(context),
                ),
              ),
              const SizedBox(height: 24),
              const PdfTemplateChooser(),
              const SizedBox(height: 24),
              Card(
                surfaceTintColor: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'אודות האפליקציה',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onTap: () {
                    context.push(const AboutScreen());
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _handleSendPasswordReset,
                icon: Icon(
                  Icons.lock_reset,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  'שליחת קישור לאיפוס סיסמה',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'התנתקות מהמערכת',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
