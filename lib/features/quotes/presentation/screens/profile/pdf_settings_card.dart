import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/firestore_service.dart';

class PdfSettingsCard extends StatefulWidget {
  final Map<String, dynamic> initialProfile;

  const PdfSettingsCard({
    super.key,
    required this.initialProfile,
  });

  @override
  State<PdfSettingsCard> createState() => _PdfSettingsCardState();
}

class _PdfSettingsCardState extends State<PdfSettingsCard> {
  final _pdfNotesController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadPdfData(widget.initialProfile);
  }

  @override
  void dispose() {
    _pdfNotesController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  void _loadPdfData(Map<String, dynamic> profile) {
    _pdfNotesController.text = profile['defaultPdfNotes'] ?? '';
    _paymentTermsController.text = profile['paymentTerms'] ?? '';
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      final dataToSave = {
        'defaultPdfNotes': _pdfNotesController.text.trim(),
        'paymentTerms': _paymentTermsController.text.trim(),
      };
      await FirestoreService.saveProfile(_uid, dataToSave);

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('הגדרות ה-PDF עודכנו בהצלחה!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשמירת הגדרות PDF: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleCancel() {
    // Reload original data to discard changes
    _loadPdfData(widget.initialProfile);
    setState(() {
      _isEditing = false;
    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'הגדרות PDF',
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
                    tooltip: 'עריכת הגדרות PDF',
                  )
                else
                  _buildEditActions(),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'הערות ברירת מחדל לתחתית ה-PDF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'תנאי תשלום ל-PDF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
