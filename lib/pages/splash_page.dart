import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'login_page.dart';

/// Splash / onboarding Leafboard (mockup kiri screenshot Auth).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header navy melengkung
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: _CurveClipper(),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * 0.42,
                    width: double.infinity,
                    color: AppColors.navy,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -36,
                  child: const Center(child: LeafLogo(size: 84)),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              'Leafboard',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'A platform built for a new way of working',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.leafGreen,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Get Started for Free',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16),
                    ],
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

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 70)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 10,
        size.width,
        size.height - 70,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
