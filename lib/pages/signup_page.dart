import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'menu_page.dart';

/// Signup — contoh state terisi, tombol Continue hijau
/// (mockup kanan screenshot Auth).
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: 'dillerragip@gmail.com');
    _password = TextEditingController(text: 'password123');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _email.text.contains('@') && _password.text.length >= 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Sign up',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(),
                const SizedBox(height: 36),
                const AuthLabel('Your email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  decoration: authInputDecoration(
                      hint: 'dillerragip@gmail.com'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const AuthLabel('Choose a password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: authInputDecoration(
                    hint: 'min. 8 characters',
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                      icon: Icon(
                        Icons.visibility_off_outlined,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                ContinueButton(
                  enabled: _canContinue,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MenuPage()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                const OrDivider(),
                const SizedBox(height: 16),
                SocialButton(
                  text: 'Sign up with Google',
                  icon: const Text('G',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.selectedBlue)),
                ),
                const SizedBox(height: 12),
                const SocialButton(
                  text: 'Sign up with Apple',
                  icon: Icon(Icons.apple, size: 20, color: Colors.black),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
