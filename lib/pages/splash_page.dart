import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_widgets.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // Adjust padding based on orientation
    final horizontalPadding = isLandscape ? 20.0 : 48.0;
    final minButtonHeight = isLandscape ? 56.0 : 44.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Column(
              children: [
                // 1. Header navy polos melengkung U (pusat lebih rendah)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        height: screenHeight * 0.40,
                        width: double.infinity,
                        color: AppColors.navy,
                      ),
                    ),
                    // Logo putih tepat menempel di titik terendah U
                    Positioned(
                      left: isLandscape ? screenWidth * 0.1 : 0,
                      right: isLandscape ? screenWidth * 0.1 : 0,
                      bottom: -44,
                      child: Center(child: LeafLogo(size: isLandscape ? 100 : 88)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 2. Judul - adaptive font size
                Text(
                  'Leafboard',
                  style: TextStyle(
                    fontSize: isLandscape ? 40 : 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Subtitle - lebar adaptive
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'A platform built for a new way of working',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLandscape ? 16 : 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // 4. Tombol pil hijau - responsif height
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: minButtonHeight,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
    // Adjust clip based on aspect ratio - landscape gets different treatment
    final isWide = w / h > 1.2;

    final path = Path()
      ..lineTo(0, h - 110)
      ..cubicTo(
        0, h + (isWide ? 30 : 20),
        w, h + (isWide ? 30 : 20),
        w, h - 110,
      )
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}