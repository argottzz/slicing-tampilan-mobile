import 'package:flutter/material.dart';
import 'login_page.dart';

// Halaman pembuka.
// Materi #9: Scaffold, Column, Container, Text, ElevatedButton.
// Materi #8: SingleChildScrollView biar tidak overflow di HP kecil.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna navy untuk header atas.
    var navy = const Color(0xFF101E33);
    // Warna hijau muda untuk tombol.
    var hijau = const Color(0xFF8DEE9C);
    // Warna hijau tua untuk logo daun.
    var hijauTua = const Color(0xFF5ED67E);
    // Tinggi header navy.
    double headerHeight = 320;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header navy atas + logo putih di tengah bawah.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(120),
                      bottomRight: Radius.circular(120),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -44,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.eco, size: 48, color: hijauTua),
                          Positioned(
                            right: 24,
                            bottom: 22,
                            child:
                                Icon(Icons.eco, size: 33, color: navy),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 76),

            // 2. Judul.
            const Text(
              'Leafboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Sub judul.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'A platform built for a new way of working',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 64),

            // 4. Tombol hijau pindah ke Login.
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijau,
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
