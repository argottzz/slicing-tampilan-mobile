import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

// File utama, hanya menampilkan SplashPage.
// Materi #1: runApp + MaterialApp.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

