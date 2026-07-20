import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:file_picker/file_picker.dart';
import 'logo_picker.dart';

class ProfileDetailsCard extends StatefulWidget {
  final Map<String, dynamic> initialProfile;

  const ProfileDetailsCard({
    super.key,
    required this.initialProfile,
  });

  @override
  State<ProfileDetailsCard> createState() => _ProfileDetailsCardState();
}

class _ProfileDetailsCardState extends State<ProfileDetailsCard> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _logoPath;
  bool _isEditing = false;
  bool _isSaving = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _email => widget.initialProfile['email'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfileData(widget.initialProfile);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadProfileData(Map<String, dynamic> profile) {
    _businessNameController.text = profile['businessName'] ?? '';
    _phoneController.text = profile['phone'] ?? '';
    _logoPath = profile['logoPath'] as String?;
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final updatedProfileData = {
        'businessName': _businessNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'logoPath': _logoPath,
      };

      await FirestoreService.saveProfile(_uid, updatedProfileData);

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('פרטי העסק עודכנו בהצלחה!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשמירת פרטי העסק: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  
  void _handleCancel() {
    // Reload the original data to discard changes
    _loadProfileData(widget.initialProfile);
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
      );

      if (result == null || result.files.single.path == null) return;

      final sourceFile = File(result.files.single.path!);
      final extension = result.files.single.extension?.toLowerCase();
      final size = result.files.single.size;

      if (size > 5 * 1024 * 1024) {
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

      await sourceFile.copy(savedPath);

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


  Widget _buildEditActions() {
    return _isSaving 
      ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: _handleCancel,
            tooltip: 'ביטול',
          ),
          IconButton(
            icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
            onPressed: _handleSave,
            tooltip: 'שמירה',
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'פרטי עסק',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => setState(() => _isEditing = true),
                      tooltip: 'עריכת פרטי עסק',
                    )
                  else
                    _buildEditActions(),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'שם העסק / פרופיל',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              TextFormField(
                controller: _businessNameController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'כתובת אימייל',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              TextFormField(
                initialValue: _email,
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  helperText: 'לא ניתן לשינוי כאן',
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'מספר טלפון',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              TextFormField(
                controller: _phoneController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android_outlined, size: 20),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
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
              const SizedBox(height: 16),
              Text(
                'לוגו עסק',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
