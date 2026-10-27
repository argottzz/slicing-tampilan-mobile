import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../model/app_user.dart';
import '../service/api.dart';
import '../service/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/info_banner.dart';

class LoginPage extends StatefulWidget {
  final ValueChanged<AppUser> onLoggedIn;
  final VoidCallback onOpenRegister;
  final bool sessionExpired;

  const LoginPage({
    super.key,
    required this.onLoggedIn,
    required this.onOpenRegister,
    this.sessionExpired = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validasiEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email wajib diisi';
    final pola = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pola.hasMatch(email)) return 'Format email tidak valid';
    return null;
  }

  String? _validasiPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password wajib diisi';
    if (password.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  Future<void> _login() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final hasil = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await ApiService.saveToken(hasil.token);

      if (!mounted) return;
      setState(() => _loading = false);
      widget.onLoggedIn(hasil.user);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Login gagal. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthHeader(
                        title: 'Masuk dan amankan tiketmu.',
                        subtitle:
                            'Pantau status pembayaran dan kelola semua tiket event dalam satu akun.',
                      ),
                      const SizedBox(height: 26),
                      Text('Masuk ke akun', style: tema.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Gunakan email dan password yang sudah terdaftar.',
                        style: tema.textTheme.bodySmall,
                      ),
                      if (widget.sessionExpired) ...[
                        const SizedBox(height: 16),
                        const InfoBanner(
                          icon: Icons.info_outline_rounded,
                          message:
                              'Sesi kamu sudah berakhir. Silakan login kembali.',
                          color: AppColors.warning,
                          background: AppColors.warningSoft,
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        InfoBanner(
                          icon: Icons.error_outline_rounded,
                          message: _error!,
                          color: AppColors.danger,
                          background: AppColors.dangerSoft,
                        ),
                      ],
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _validasiEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: _validasiPassword,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Tampilkan password'
                                : 'Sembunyikan password',
                            onPressed: () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Masuk'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'atau',
                              style: tema.textTheme.bodySmall,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : widget.onOpenRegister,
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: const Text('Buat akun baru'),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Text(
                          'GATIX • Event Ticketing',
                          style: tema.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.muted.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
