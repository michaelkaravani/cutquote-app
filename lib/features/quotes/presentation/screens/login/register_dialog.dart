import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_error_handler.dart';

Future<void> showRegisterDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var isPasswordVisible = false;
  var isLoading = false;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (dialogContext, dialogSetState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'יצירת חשבון חדש',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabeledField(
                        context: context,
                        label: 'כתובת אימייל',
                        controller: emailController,
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'אנא הזן אימייל';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'אימייל לא תקין';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildLabeledField(
                        context: context,
                        label: 'סיסמה',
                        controller: passwordController,
                        hintText: 'לפחות 6 תווים',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          onPressed: () {
                            dialogSetState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'אנא הזן סיסמה';
                          }
                          if (value.length < 6) {
                            return 'הסיסמה קצרה מדי';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildLabeledField(
                        context: context,
                        label: 'אימות סיסמה',
                        controller: confirmPasswordController,
                        hintText: 'הקלד את הסיסמה שנית',
                        prefixIcon: Icons.lock_clock_outlined,
                        obscureText: !isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'אנא אשר את הסיסמה';
                          }
                          if (value != passwordController.text) {
                            return 'הסיסמאות אינן תואמות';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'ביטול',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            dialogSetState(() => isLoading = true);

                            final navigator = Navigator.of(dialogContext);
                            final messenger = ScaffoldMessenger.of(context);
                            final accentColor = Theme.of(context).colorScheme.secondary;

                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                              );

                              if (userCredential.user != null) {
                                await userCredential.user!.sendEmailVerification();
                                await FirebaseAuth.instance.signOut();
                              }

                              navigator.pop();

                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'החשבון נוצר בהצלחה! אימייל אימות נשלח לתיבת הדואר שלך.',
                                  ),
                                  backgroundColor: accentColor,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(friendlyAuthError(e)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('שגיאה: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } finally {
                              if (dialogContext.mounted) {
                                dialogSetState(() => isLoading = false);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('הרשמה'),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  emailController.dispose();
  passwordController.dispose();
  confirmPasswordController.dispose();
}

Widget _buildLabeledField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hintText,
  required IconData prefixIcon,
  bool obscureText = false,
  Widget? suffixIcon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, size: 18),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    ],
  );
}
