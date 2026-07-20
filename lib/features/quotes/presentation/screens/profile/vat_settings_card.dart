import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/firestore_service.dart';

class VatSettingsCard extends StatefulWidget {
  final Map<String, dynamic> initialProfile;

  const VatSettingsCard({
    super.key,
    required this.initialProfile,
  });

  @override
  State<VatSettingsCard> createState() => _VatSettingsCardState();
}

class _VatSettingsCardState extends State<VatSettingsCard> {
  final _vatRateController = TextEditingController();
  bool _vatExempt = false;
  Timer? _debounce;
  bool _isSaving = false;
  bool _justSaved = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _vatExempt = widget.initialProfile['vatExempt'] == true;
    _vatRateController.text =
        (((widget.initialProfile['vatRate'] as num?)?.toDouble() ?? 0.17) * 100)
            .toStringAsFixed(1);
  }

  @override
  void dispose() {
    _vatRateController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _handleAutoSave() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      final vatRate = double.tryParse(_vatRateController.text);
      if (vatRate == null || vatRate < 0 || vatRate > 100) {
        return; // Don't save invalid values
      }

      setState(() => _isSaving = true);
      try {
        final dataToSave = {
          'vatRate': _vatExempt ? 0.0 : (vatRate / 100),
          'vatExempt': _vatExempt,
        };
        await FirestoreService.saveProfile(_uid, dataToSave);
        
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _justSaved = true;
        });
        // Hide the 'Saved' checkmark after a couple of seconds
        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _justSaved = false);
        });

      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשמירת הגדרות מע"מ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
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
                  'הגדרות מע"מ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (_isSaving)
                  const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else if (_justSaved)
                  Icon(Icons.check_circle, color: Colors.green.shade600),
              ],
            ),
             const SizedBox(height: 4),
            Text(
              'השינויים נשמרים אוטומטית',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'אחוז מע"מ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'לדוגמה: 17',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            TextFormField(
              controller: _vatRateController,
              enabled: !_vatExempt,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _handleAutoSave(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.percent, size: 20),
                filled: true,
                fillColor: _vatExempt
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Theme.of(context).colorScheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'עוסק פטור ממע"מ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: const Text(
                'אינו גובה מע"מ ואינו מנכה מע"מ',
                style: TextStyle(fontSize: 12),
              ),
              value: _vatExempt,
              onChanged: (value) {
                setState(() {
                  _vatExempt = value;
                  if (value) {
                    _vatRateController.text = '0';
                  }
                });
                _handleAutoSave();
              },
            ),
          ],
        ),
      ),
    );
  }
}
