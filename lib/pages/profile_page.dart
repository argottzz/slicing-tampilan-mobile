import 'package:flutter/material.dart';

// Profile - foto, nama, dan info kontak.
// Materi #9: Column, Container, Row, Icon, Text.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna navy untuk ikon.
    var navy = const Color(0xFF101E33);
    // Warna abu garis.
    var garis = const Color(0xFFE9E4DC);
    // Warna abu teks kecil.
    var abu = const Color(0xFFB9B3A8);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Foto profil lingkaran.
          Container(
            width: 124,
            height: 124,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: garis,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Foto profil lingkaran.
          Container(
            width: 124,
            height: 124,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: garis,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Alex Gilles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: garis),
            ),
            child: Column(
              children: [
                // Baris phone.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.phone_outlined,
                            size: 18, color: navy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PHONE',
                                style:
                                    TextStyle(fontSize: 10, color: abu)),
                            const SizedBox(height: 2),
                            const Text('+7 904 599 XXX 11',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Baris email.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.mail_outlined,
                            size: 18, color: navy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EMAIL',
                                style:
                                    TextStyle(fontSize: 10, color: abu)),
                            const SizedBox(height: 2),
                            const Text('alexg@gmail.com',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Baris alamat.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.location_on_outlined,
                            size: 18, color: navy),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ADDRESS',
                                style: TextStyle(fontSize: 10)),
                            SizedBox(height: 2),
                            Text('St. Petersburg, Vos...',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}