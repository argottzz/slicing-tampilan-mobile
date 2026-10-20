import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {

  final Map<String, Permission> _items = {
    'Kamera': Permission.camera,
    'Lokasi': Permission.locationWhenInUse,
    'Kontak': Permission.contacts,
    'Foto / Galeri (Android 13+, iOS)': Permission.photos,
    'Penyimpanan (Android 12 ke bawah)': Permission.storage,
    'Mikrofon': Permission.microphone,
    'Notifikasi': Permission.notification,
  };

  final Map<String, PermissionStatus> _status = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  Future<void> _refreshAll() async {
    for (final entry in _items.entries) {
      final status = await entry.value.status;
      _status[entry.key] = status;
    }
    if (mounted) setState(() {});
  }

  Future<void> _request(String name, Permission permission) async {
    // Ini yang memunculkan dialog izin di HP.
    final result = await permission.request();
    debugPrint('Izin $name: $result');
    if (!mounted) return;
    setState(() => _status[name] = result);
    if (result.isPermanentlyDenied) {
      _showSettingsDialog(name);
    }
  }

  void _showSettingsDialog(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izin ditolak permanen'),
        content: Text(
          'Izin $name sudah ditolak permanen. '
          'Buka Pengaturan untuk mengaktifkannya secara manual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Membuka pengaturan aplikasi
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  String _label(PermissionStatus? s) {
    if (s == null) return 'Memeriksa...';
    if (s.isGranted) return 'Diizinkan';
    if (s.isPermanentlyDenied) return 'Ditolak permanen';
    if (s.isDenied) return 'Belum diizinkan / ditolak';
    if (s.isRestricted) return 'Dibatasi sistem';
    if (s.isLimited) return 'Akses terbatas';
    return s.toString();
  }

  Color _color(PermissionStatus? s) {
    if (s == null) return Colors.grey;
    if (s.isGranted || s.isLimited) return Colors.green;
    if (s.isPermanentlyDenied) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Permission')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _items.entries.map((entry) {
          final status = _status[entry.key];
          return Card(
            child: ListTile(
              title: Text(entry.key),
              subtitle: Text(
                _label(status),
                style: TextStyle(color: _color(status)),
              ),
              trailing: ElevatedButton(
                onPressed: () => _request(entry.key, entry.value),
                child: const Text('Minta Izin'),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
