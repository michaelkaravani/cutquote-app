import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isRegPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _openRegisterDialog() {
    _regEmailController.clear();
    _regPasswordController.clear();
    _regConfirmPasswordController.clear();

    showDialog(
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
                    key: _registerFormKey,
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
                          controller: _regEmailController,
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
                          controller: _regPasswordController,
                          obscureText: !_isRegPasswordVisible,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'לפחות 6 תווים',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 18,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isRegPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                              ),
                              onPressed: () {
                                dialogSetState(() {
                                  _isRegPasswordVisible =
                                      !_isRegPasswordVisible;
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
                          controller: _regConfirmPasswordController,
                          obscureText: !_isRegPasswordVisible,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                            hintText: 'הקלד את הסיסמה שנית',
                            prefixIcon: Icon(
                              Icons.lock_clock_outlined,
                              size: 18,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'אנא אשר את הסיסמה';
                            }
                            if (value != _regPasswordController.text) {
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
                    onPressed: _isLoading
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_registerFormKey.currentState?.validate() ?? false) {
                              dialogSetState(() {
                                _isLoading = true;
                              });

                              // 1. שמירת המצביעים לקונטקסטים השונים לפני תחילת הריצה האסינכרונית
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
                                          email: _regEmailController.text
                                              .trim(),
                                          password: _regPasswordController
                                              .text,
                                        );

                                if (userCredential.user != null) {
                                  await userCredential.user
                                      ?.sendEmailVerification();
                                  await FirebaseAuth.instance.signOut();
                                }

                                // 2. שימוש בבטחה במצביעים ששמרנו מראש (ללא שימוש ישיר ב-Context)
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
                                    content: Text(_friendlyAuthError(e)),
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
                                    _isLoading = false;
                                  });
                                } else {
                                  _isLoading = false;
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
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
  }

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'אנא הזן כתובת אימייל תקינה בשדה ההתחברות לשחזור הסיסמה',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // פתרון שגיאה מספר 3: בדיקה שהקומפוננטה מחוברת לסיסטם לפני פתיחת דיאלוג נוסף
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
              title: Text(
                'אימות נשלח',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'קישור מאובטח לאיפוס הסיסמה נשלח לכתובת:\n${_emailController.text}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                  child: Text(
                    'הבנתי',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                ),
              ),
            ],
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyAuthError(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשליחת השחזור: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'שם המשתמש או הסיסמה שגויים';
      case 'invalid-email':
        return 'כתובת האימייל אינה תקינה';
      case 'user-disabled':
        return 'החשבון הושבת';
      case 'too-many-requests':
        return 'יותר מדי ניסיונות כושלים. אנא נסה מאוחר יותר';
      case 'network-request-failed':
        return 'בעיית רשת, אנא בדוק את החיבור שלך';
      case 'email-already-in-use':
        return 'כתובת האימייל כבר רשומה במערכת';
      case 'weak-password':
        return 'הסיסמה חייבת להכיל לפחות 6 תווים';
      default:
        return 'שגיאת התחברות: ${e.message}';
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          await FirebaseAuth.instance.signOut();

          // פתרון שגיאה מספר 5: מניעת קריאה ל-Context מחוץ לסטייט אם המשתמש לא אימת מייל
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'חשבונך טרם אומת. שלחנו לך מייל אימות חדש, אנא בדוק את תיבת הדואר שלך.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        if (!mounted) return;
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyAuthError(e)),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: const Text(
                          'CQ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'CutQuote Pro',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'מערכת ניהול וחישוב הצעות מחיר לייצור',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    Text(
                      'כתובת אימייל',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'אנא הזן כתובת אימייל';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'אנא הזן כתובת אימייל תקינה';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'סיסמה',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'הזן את סיסמתך',
                        hintStyle: const TextStyle(color: Colors.black26),
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'אנא הזן סיסמה';
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'שכחתי סיסמה...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'התחברות למערכת',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'אין לך חשבון עדיין?',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _openRegisterDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                            child: Text(
                              'הרשמה כאן',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
