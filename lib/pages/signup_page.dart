import 'package:flutter/material.dart';
import 'menu_page.dart';

// Halaman signup.
// Materi #4: TextField, InputDecoration.
// Materi #9: Scaffold, Column, Row, Text.
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna hijau tua untuk logo daun.
    var hijauTua = const Color(0xFF5ED67E);
    // Warna abu garis input.
    var garis = const Color(0xFFE9E4DC);
    // Warna abu teks hint.
    var hint = const Color(0xFFB9B3A8);
    // Warna abu tombol.
    var abuTombol = const Color(0xFFF0EFEF);
    // Warna abu teks tombol.
    var abuTeks = const Color(0xFFB5B5B5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul atas.
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 26, color: Color(0xFF5ED67E)),
                  SizedBox(width: 6),
                  Text(
                    'Leafboard',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Work without limits',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 36),

              // Email.
              const Text(
                'Your email address',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'dillerragip@gmail.com',
                  hintStyle: TextStyle(fontSize: 13, color: hint),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: garis),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: hijauTua),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Password.
              const Text(
                'Choose a password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'min. 8 characters',
                  hintStyle: TextStyle(fontSize: 13, color: hint),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: garis),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: hijauTua),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Tombol Continue pindah ke Menu.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenuPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: abuTombol,
                    foregroundColor: abuTeks,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Garis or.
              Row(
                children: [
                  Expanded(child: Divider(color: garis)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(fontSize: 12, color: hint),
                    ),
                  ),
                  Expanded(child: Divider(color: garis)),
                ],
              ),
              const SizedBox(height: 16),

              // Tombol Google, hanya tampilan.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: garis),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'G',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sign up with Google',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Apple, hanya tampilan.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: garis),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 20, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Sign up with Apple',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
