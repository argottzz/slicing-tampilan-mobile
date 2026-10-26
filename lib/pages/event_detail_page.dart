import 'package:flutter/material.dart';
import 'package:tugas_slicing/service/api.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool loading = true;
  String error = '';
  Map<String, dynamic>? event;
  bool registering = false;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final res = await ApiService.get('/events/${widget.eventId}');
      event = res['data'];
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> register() async {
    setState(() => registering = true);
    try {
      await ApiService.post('/registrations', {'event_id': widget.eventId});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mendaftar event')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => registering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error.isNotEmpty || event == null) {
      return Scaffold(body: Center(child: Text(error.isEmpty ? 'Event tidak ditemukan' : error)));
    }
    final e = event!;
    return Scaffold(
      appBar: AppBar(title: Text(e['title'] ?? 'Detail Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Lokasi: ${e['location'] ?? '-'}'),
            Text('Tanggal: ${e['date'] ?? '-'}'),
            Text('Harga: ${e['price'] ?? 0}'),
            Text('Sisa kuota: ${e['available_quota'] ?? e['quota'] ?? 0}'),
            const SizedBox(height: 12),
            Text(e['description'] ?? ''),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: registering ? null : register,
                child: registering
                    ? const CircularProgressIndicator()
                    : const Text('Daftar Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
