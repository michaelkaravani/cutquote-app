import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/core/theme_notifier.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import 'pdf_templates_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vatRateController = TextEditingController();
  final _pdfNotesController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  String? _logoPath;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final Color accentOrange = const Color(0xFFE88432);

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  String get _email => FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _vatRateController.dispose();
    _pdfNotesController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final profile = await FirestoreService.loadProfile(_uid);
      if (!mounted) return;
      setState(() {
        _businessNameController.text = profile?['businessName'] ?? '';
        _phoneController.text = profile?['phone'] ?? '';
        _vatRateController.text = (profile?['vatRate'] ?? 0.18).toString();
        _pdfNotesController.text = profile?['defaultPdfNotes'] ?? '';
        _paymentTermsController.text = profile?['paymentTerms'] ?? '';
        _logoPath = profile?['logoPath'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בטעינת הפרופיל: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirestoreService.saveProfile(_uid, {
        'businessName': _businessNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'vatRate': double.tryParse(_vatRateController.text) ?? 0.18,
        'logoPath': _logoPath,
        'defaultPdfNotes': _pdfNotesController.text.trim(),
        'paymentTerms': _paymentTermsController.text.trim(),
      });

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('הפרטים עודכנו ונשמרו בהצלחה!'),
          backgroundColor: accentOrange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשמירת הפרופיל: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleSendPasswordReset() async {
    if (_email.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('קישור לאיפוס סיסמה נשלח לכתובת:\n$_email'),
          backgroundColor: accentOrange,
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
      case ThemeMode.system:
        return 'ברירת מחדל של המערכת';
      case ThemeMode.light:
        return 'מצב בהיר';
      case ThemeMode.dark:
        return 'מצב כהה';
    }
  }

  String _pdfTemplateLabel(String template) {
    switch (template) {
      case 'premium_dark':
        return 'יוקרתי כהה';
      case 'clean_corporate':
        return 'תאגידי נקי';
      case 'natural_craft':
        return 'קראפטי טבעי';
      case 'minimal_stone':
        return 'מינימל אבן';
      case 'modern_bordeaux':
        return 'מודרני בורדו';
      default:
        return 'יוקרתי כהה';
    }
  }

  void _showThemePicker() {
    final current = themeNotifier.themeMode;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ערכת נושא',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _themeOption(
                ctx,
                icon: Icons.brightness_auto,
                label: 'ברירת מחדל של המערכת',
                mode: ThemeMode.system,
                isSelected: current == ThemeMode.system,
              ),
              _themeOption(
                ctx,
                icon: Icons.light_mode,
                label: 'מצב בהיר',
                mode: ThemeMode.light,
                isSelected: current == ThemeMode.light,
              ),
              _themeOption(
                ctx,
                icon: Icons.dark_mode,
                label: 'מצב כהה',
                mode: ThemeMode.dark,
                isSelected: current == ThemeMode.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(ctx).colorScheme.primary),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
          : null,
      onTap: () {
        Navigator.pop(ctx);
        themeNotifier.setThemeMode(mode);
      },
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'business_logo_${DateTime.now().millisecondsSinceEpoch}.${picked.path.split('.').last}';
      final savedPath = '${dir.path}/$fileName';
      await File(picked.path).copy(savedPath);

      setState(() {
        _logoPath = savedPath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשמירת הלוגו: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
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
          title: const Text('פרופיל משתמש'),
          actions: [
            if (!_isEditing) ...{
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
            },
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                      Text(
                        _businessNameController.text.isEmpty
                            ? 'שם העסק שלך'
                            : _businessNameController.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'מנהל מערכת',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  surfaceTintColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'שם העסק / פרופיל',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          controller: _businessNameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.storefront_outlined,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'כתובת אימייל',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          initialValue: _email,
                          enabled: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            helperText: 'לא ניתן לשינוי כאן',
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'מספר טלפון',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          controller: _phoneController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone_android_outlined,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'אחוז מע"מ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          controller: _vatRateController,
                          enabled: _isEditing,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.percent,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'לוגו עסק',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _logoPath != null &&
                                      File(_logoPath!).existsSync()
                                  ? Image.file(
                                      File(_logoPath!),
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _defaultLogoPreview(),
                                    )
                                  : _defaultLogoPreview(),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: _pickLogo,
                                icon: const Icon(Icons.image, size: 18),
                                label: const Text('בחר לוגו'),
                              ),
                              if (_logoPath != null) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _logoPath = null),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'הערות ברירת מחדל לתחתית ה-PDF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _pdfNotesController,
                          enabled: _isEditing,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'לדוגמה: הצעת המחיר בתוקף ל-30 יום',
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'תנאי תשלום ל-PDF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _paymentTermsController,
                          enabled: _isEditing,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText:
                                'לדוגמה: תשלום עם קבלת ההצעה',
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing) ...{
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'שמירת שינויים',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => setState(() => _isEditing = false),
                    child: const Text('ביטול'),
                  ),
                },
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
                    subtitle: Text(
                      _themeModeLabel(themeNotifier.themeMode),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    onTap: _showThemePicker,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  surfaceTintColor: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text(
                      'תבניות PDF',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _pdfTemplateLabel(pdfTemplateNotifier.currentTemplate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PdfTemplatesScreen(),
                        ),
                      );
                    },
                  ),
                ),
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
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
      ),
    );
  }

  Widget _defaultLogoPreview() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.business_rounded,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
