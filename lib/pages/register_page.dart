import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'menu_page.dart';

// Register — desain disamakan persis dengan Login/Auth.
// Satu sistem: header, input pil, Continue dinamis, divider, social.
// Ditambahkan responsive untuk handphone landscape & potrait.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  bool get _canRegister =>
      _name.text.trim().length >= 3 &&
      _email.text.contains('@') &&
      _password.text.length >= 8 &&
      _confirm.text == _password.text &&
      _confirm.text.isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // Adaptive padding: lebih kecil di landscape
    final horizontalPadding = isLandscape ? 16.0 : 20.0;
    final fontSize = isLandscape ? 14.0 : 13.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(),
                    const SizedBox(height: 36),
                    AuthLabel('Full name',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      decoration:
                          authInputDecoration(hint: 'Ralph Fernando'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        if (v.trim().length < 3) return 'Minimal 3 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AuthLabel('Your email address',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
                    AuthLabel('Choose a password',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure1,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      decoration: authInputDecoration(
                        hint: 'min. 8 characters',
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.inputHint,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (v.length < 8) return 'Minimal 8 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AuthLabel('Confirm password',
                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure2,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      decoration: authInputDecoration(
                        hint: 'repeat your password',
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.inputHint,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v != _password.text) {
                          return 'Konfirmasi tidak sama';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    ContinueButton(
                      enabled: _canRegister,
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
                    const SocialButton(
                      text: 'Sign up with Google',
                      icon: GoogleGIcon(size: 20),
                    ),
                    const SizedBox(height: 12),
                    const SocialButton(
                      text: 'Sign up with Apple',
                      icon: Icon(Icons.apple, size: 20, color: Colors.black),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? ',
                            style: TextStyle(fontSize: 12)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Login',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AuthLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const AuthLabel(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );
  }
}