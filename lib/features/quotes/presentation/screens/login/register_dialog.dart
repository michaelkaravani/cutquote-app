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
                      Text(
                        'כתובת אימייל',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 18),
                        ),
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
                      Text(
                        'סיסמה',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'לפחות 6 תווים',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
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
                      Text(
                        'אימות סיסמה',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !isPasswordVisible,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'הקלד את הסיסמה שנית',
                          prefixIcon: Icon(Icons.lock_clock_outlined, size: 18),
                        ),
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
                      : () {
                          Navigator.pop(dialogContext);
                        },
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
                            dialogSetState(() {
                              isLoading = true;
                            });

                            final NavigatorState dialogNavigator =
                                Navigator.of(dialogContext);
                            final ScaffoldMessengerState messenger =
                                ScaffoldMessenger.of(context);
                            final Color accentColor =
                                Theme.of(context).colorScheme.secondary;

                            try {
                              UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                      );

                              if (userCredential.user != null) {
                                await userCredential.user
                                    ?.sendEmailVerification();
                                await FirebaseAuth.instance.signOut();
                              }

                              dialogNavigator.pop();

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
                                dialogSetState(() {
                                  isLoading = false;
                                });
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
