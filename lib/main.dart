import 'dart:async';

import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'model/app_user.dart';
import 'pages/login_page.dart';
import 'pages/main_shell.dart';
import 'pages/register_page.dart';
import 'pages/splash_page.dart';
import 'service/api.dart';
import 'service/auth_service.dart';
import 'widgets/brand_mark.dart';
import 'widgets/state_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GATIX',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: AppTheme.build(),
      home: const AuthGate(),
    );
  }
}

enum _StatusAuth { memeriksa, masuk, belumMasuk, gagal }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  _StatusAuth _status = _StatusAuth.memeriksa;
  AppUser? _user;
  String _error = '';
  bool _tampilDaftar = false;
  bool _sesiBerakhir = false;

  @override
  void initState() {
    super.initState();
    ApiService.onUnauthorized = () => unawaited(_sesiHabis());
    _cekSesi();
  }

  @override
  void dispose() {
    ApiService.onUnauthorized = null;
    super.dispose();
  }

  Future<void> _sesiHabis() async {
    await ApiService.clearToken();
    rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);

    if (!mounted) return;
    setState(() {
      _status = _StatusAuth.belumMasuk;
      _user = null;
      _tampilDaftar = false;
      _sesiBerakhir = true;
    });
  }

  Future<void> _cekSesi() async {
    setState(() {
      _status = _StatusAuth.memeriksa;
      _error = '';
    });

    try {
      final token = await ApiService.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() => _status = _StatusAuth.belumMasuk);
        return;
      }

      final user = await AuthService.me();
      if (!mounted) return;

      setState(() {
        _user = user;
        _status = _StatusAuth.masuk;
        _sesiBerakhir = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.statusCode == 401 || error.statusCode == 403) {
        await ApiService.clearToken();
        if (!mounted) return;
        setState(() {
          _status = _StatusAuth.belumMasuk;
          _user = null;
          _sesiBerakhir = error.statusCode == 401;
        });
      } else {
        setState(() {
          _status = _StatusAuth.gagal;
          _error = error.message;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _StatusAuth.gagal;
        _error = 'Tidak dapat memeriksa sesi. Pastikan server dapat diakses.';
      });
    }
  }

  void _setelahMasuk(AppUser user) {
    setState(() {
      _user = user;
      _status = _StatusAuth.masuk;
      _tampilDaftar = false;
      _sesiBerakhir = false;
    });
  }

  void _userBerubah(AppUser user) {
    setState(() => _user = user);
  }

  Future<void> _keluar() async {
    await ApiService.clearToken();
    rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);

    if (!mounted) return;
    setState(() {
      _user = null;
      _status = _StatusAuth.belumMasuk;
      _tampilDaftar = false;
      _sesiBerakhir = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _StatusAuth.memeriksa:
        return const SplashPage();

      case _StatusAuth.gagal:
        return _LayarGagal(
          pesan: _error,
          onCobaLagi: _cekSesi,
        );

      case _StatusAuth.masuk:
        return MainShell(
          user: _user!,
          onUserChanged: _userBerubah,
          onLogout: _keluar,
        );

      case _StatusAuth.belumMasuk:
        if (_tampilDaftar) {
          return RegisterPage(
            onRegistered: _setelahMasuk,
            onBackToLogin: () => setState(() => _tampilDaftar = false),
          );
        }

        return LoginPage(
          onLoggedIn: _setelahMasuk,
          onOpenRegister: () => setState(() => _tampilDaftar = true),
          sessionExpired: _sesiBerakhir,
        );
    }
  }
}

class _LayarGagal extends StatelessWidget {
  final String pesan;
  final VoidCallback onCobaLagi;

  const _LayarGagal({required this.pesan, required this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BrandMark(size: 34),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ErrorState(
                    title: 'Tidak dapat terhubung',
                    message: pesan,
                    onRetry: onCobaLagi,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
