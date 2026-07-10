import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController(
    text: 'מיכאל פרסיז׳ן ארט',
  );
  final _emailController = TextEditingController(text: 'micha@example.com');
  final _phoneController = TextEditingController(text: '050-1234567');
  final _passwordController = TextEditingController(text: '123456');

  bool _isEditing = false;
  bool _isPasswordVisible = false;

  final Color backgroundColor = const Color(0xFFFAF7F0);
  final Color primaryDark = const Color(0xFF513222);
  final Color accentOrange = const Color(0xFFE88432);
  final Color cardColor = Colors.white;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('הפרטים עודכנו ונשמרו בהצלחה!'),
          backgroundColor: accentOrange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'פרופיל משתמש',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryDark,
          elevation: 0,
          actions: [
            if (!_isEditing) ...{
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
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
                        backgroundColor: primaryDark,
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _businessNameController.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      const Text(
                        'מנהל מערכת',
                        style: TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  color: cardColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'שם העסק / פרופיל',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                            fillColor: _isEditing
                                ? Colors.white
                                : Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'כתובת אימייל',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: _isEditing
                                ? Colors.white
                                : Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'מספר טלפון',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          controller: _phoneController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone_android_outlined,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: _isEditing
                                ? Colors.white
                                : Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'סיסמת גישה במכשיר',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          enabled: _isEditing,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: _isEditing
                                ? Colors.white
                                : Colors.grey[50],
                            suffixIcon: _isEditing
                                ? IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing) ...{
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'שמירת שינויים',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('ביטול'),
                  ),
                },
                const SizedBox(height: 40),
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
