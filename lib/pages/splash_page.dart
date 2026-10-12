import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Header navy polos melengkung U (pusat lebih rendah)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    height: screenHeight * 0.44,
                    width: double.infinity,
                    color: AppColors.navy,
                  ),
                ),
                // Logo putih tepat menempel di titik terendah U
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: -44,
                  child: Center(child: LeafLogo(size: 88)),
                ),
              ],
            ),

            const SizedBox(height: 76),

            // 2. Judul
            const Text(
              'Leafboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.6,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'A platform built for a new way of working',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(),

            // 4. Tombol pil hijau kecil di tengah seperti foto
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
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
                      Text(
                        'Get Started for Free',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

/// Navy polos seperti foto: sisi kiri/kanan lurus vertikal dulu
/// sampai (h-110), baru menikuk membulat ke dasar U (~h-12).
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..lineTo(0, h - 110)
      ..cubicTo(
        0, h + 20,
        w, h + 20,
        w, h - 110,
      )
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}