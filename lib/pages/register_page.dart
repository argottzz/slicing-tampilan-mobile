import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../model/app_user.dart';
import '../service/api.dart';
import '../service/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/info_banner.dart';

class RegisterPage extends StatefulWidget {
  final ValueChanged<AppUser> onRegistered;
  final VoidCallback onBackToLogin;

  const RegisterPage({
    super.key,
    required this.onRegistered,
    required this.onBackToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validasiNama(String? value) {
    final nama = (value ?? '').trim();
    if (nama.isEmpty) return 'Nama wajib diisi';
    if (nama.length < 3) return 'Nama minimal 3 karakter';
    if (nama.length > 100) return 'Nama maksimal 100 karakter';
    return null;
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

  String? _validasiKonfirmasi(String? value) {
    if ((value ?? '').isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  Future<void> _register() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final hasil = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await ApiService.saveToken(hasil.token);

      if (!mounted) return;
      setState(() => _loading = false);
      widget.onRegistered(hasil.user);
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
        _error = 'Pendaftaran gagal. Silakan coba lagi.';
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
                        title: 'Buat akun dan mulai jelajah.',
                        subtitle:
                            'Satu akun untuk memesan tiket, memantau pembayaran, dan mengelola event.',
                      ),
                      const SizedBox(height: 26),
                      Text('Daftar akun', style: tema.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Isi data berikut sesuai identitasmu.',
                        style: tema.textTheme.bodySmall,
                      ),
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
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        validator: _validasiNama,
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                          hintText: 'Nama sesuai identitas',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validasiPassword,
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
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        validator: _validasiKonfirmasi,
                        onFieldSubmitted: (_) => _register(),
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi password',
                          hintText: 'Ulangi password',
                          prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Daftar'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : widget.onBackToLogin,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Sudah punya akun? Masuk'),
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
