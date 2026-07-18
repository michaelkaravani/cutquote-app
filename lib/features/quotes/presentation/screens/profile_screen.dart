import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/navigation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/core/app_theme.dart';
import 'package:cutquote/core/theme_notifier.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/logo_picker.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/theme_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cutquote/features/quotes/presentation/screens/profile/pdf_template_chooser.dart';
import 'about_screen.dart';

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
  bool _vatExempt = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
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
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final profile = await FirestoreService.loadProfile(_uid);
      if (!mounted) return;
      setState(() {
        _businessNameController.text = profile?['businessName'] ?? '';
        _phoneController.text = profile?['phone'] ?? '';
        _vatRateController.text =
            (((profile?['vatRate'] as num?)?.toDouble() ?? 0.17) * 100)
                .toStringAsFixed(1);

        _pdfNotesController.text = profile?['defaultPdfNotes'] ?? '';
        _paymentTermsController.text = profile?['paymentTerms'] ?? '';
        _vatExempt = profile?['vatExempt'] == true;
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('התנתקות'),
          content: const Text('האם אתה בטוח שברצונך להתנתק?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ביטול', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('התנתק'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirestoreService.saveProfile(_uid, {
        'businessName': _businessNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'vatRate': _vatExempt
            ? 0.0
            : ((double.tryParse(_vatRateController.text) ?? 17) / 100),
        'vatExempt': _vatExempt,
        'logoPath': _logoPath,
        'defaultPdfNotes': _pdfNotesController.text.trim(),
        'paymentTerms': _paymentTermsController.text.trim(),
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
      });

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('הפרטים עודכנו ונשמרו בהצלחה!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
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
      case ThemeMode.system:
        return 'ברירת מחדל של המערכת';
      case ThemeMode.light:
        return 'מצב בהיר';
      case ThemeMode.dark:
        return 'מצב כהה';
    }
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = result.files.single;
      final sourceFile = File(file.path!);
      final extension = file.extension?.toLowerCase();

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הקובץ גדול מדי. המגבלה היא 5MB.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      var isValid = false;
      if (extension == 'svg') {
        final svgContent = await sourceFile.readAsString();
        final svgRootPattern = RegExp(r'<svg(?:\s|>)', caseSensitive: false);
        isValid =
            svgRootPattern.hasMatch(svgContent) &&
            svgContent.toLowerCase().contains('</svg>');
      } else if (extension == 'png' ||
          extension == 'jpg' ||
          extension == 'jpeg') {
        isValid = img.decodeImage(await sourceFile.readAsBytes()) != null;
      }

      if (!isValid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('קובץ הלוגו פגום או אינו בפורמט נתמך.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'business_logo_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final savedPath = '${dir.path}/$fileName';

      // Copy the file to a persistent location
      await File(file.path!).copy(savedPath);

      if (!mounted) return;
      setState(() {
        _logoPath = savedPath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בבחירת הלוגו: $e'),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'כתובת אימייל',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            helperText: 'לא ניתן לשינוי כאן',
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'מספר טלפון',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^[\d+\- ]+$').hasMatch(value)) {
                              return 'מספר טלפון לא תקין';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'אחוז מע"מ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'לדוגמה: 17',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        TextFormField(
                          controller: _vatRateController,
                          enabled: _isEditing && !_vatExempt,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.percent, size: 20),
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'אנא הזן אחוז מע"מ';
                            }
                            final vat = double.tryParse(value.trim());
                            if (vat == null || vat < 0 || vat > 100) {
                              return 'אחוז לא תקין (0-100)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'עוסק פטור ממע"מ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'אינו גובה מע"מ ואינו מנכה מע"מ',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _vatExempt,
                          onChanged: _isEditing
                              ? (value) {
                                  setState(() {
                                    _vatExempt = value;
                                    if (value) {
                                      _vatRateController.text = '0';
                                    }
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'לוגו עסק',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LogoPicker(
                          logoPath: _logoPath,
                          isEditing: _isEditing,
                          onPickLogo: _pickLogo,
                          onClearLogo: () => setState(() => _logoPath = null),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "לשקיפות מלאה, העלה קובץ SVG עם רקע שקוף",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'הערות ברירת מחדל לתחתית ה-PDF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _pdfNotesController,
                          enabled: _isEditing,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'לדוגמה: הצעת המחיר בתוקף ל-30 יום',
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'תנאי תשלום ל-PDF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _paymentTermsController,
                          enabled: _isEditing,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'לדוגמה: תשלום עם קבלת ההצעה',
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
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
                      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                    subtitle: ListenableBuilder(
                      listenable: themeNotifier,
                      builder: (context, _) => Text(
                        '${themeNotifier.themeStyle.label} • ${_themeModeLabel(themeNotifier.themeMode)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
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
      ),
    );
  }
}
