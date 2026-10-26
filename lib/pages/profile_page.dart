import 'package:flutter/material.dart';
import 'package:tugas_slicing/service/api.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  String name = '';
  String email = '';
  String role = 'user';
  String error = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final res = await ApiService.get('/auth/me');
      final data = res['data'];
      setState(() {
        name = data['name'] ?? '';
        email = data['email'] ?? '';
        role = data['role'] ?? 'user';
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        loading = false;
      });
    }
  }

  Future<void> becomeOrganizer() async {
    try {
      final res = await ApiService.post('/auth/become-organizer', {});
      await ApiService.saveToken(res['token']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil jadi organizer')),
      );
      loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

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

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }

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
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(fontSize: 13, color: abu)),
          const SizedBox(height: 4),
          Text('Role: $role', style: TextStyle(fontSize: 13, color: abu)),
          const SizedBox(height: 16),
          if (role != 'organizer')
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: becomeOrganizer,
                child: const Text('Jadi Organizer'),
              ),
            ),
          const SizedBox(height: 16),
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
