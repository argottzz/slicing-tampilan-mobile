import 'package:flutter/material.dart';
import 'package:tugas_slicing/service/api.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ApiService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var navy = const Color(0xFF101E33);
    var garis = const Color(0xFFE9E4DC);
    var abu = const Color(0xFFB9B3A8);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 124,
            height: 124,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: garis,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/higuruma_pp.jpg',
              fit: BoxFit.cover,
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'Logout',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE26D5A),
                side: BorderSide(color: garis),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}