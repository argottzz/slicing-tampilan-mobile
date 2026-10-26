import 'package:flutter/material.dart';
import 'package:tugas_slicing/service/api.dart';
import 'event_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  String error = '';
  List<dynamic> events = [];
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final meRes = await ApiService.get('/auth/me');
      currentUserId = meRes['data']['id'];

      final eventRes = await ApiService.get('/events');
      events = eventRes['data'] ?? [];
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteEvent(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text('Yakin ingin menghapus event ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.delete('/events/$id');
      loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          final isOwner = currentUserId != null && e['created_by'] == currentUserId;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(e['location'] ?? '', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Tanggal: ${e['date'] ?? ''}', style: const TextStyle(fontSize: 12)),
                  Text('Harga: ${e['price'] ?? 0}', style: const TextStyle(fontSize: 12)),
                  Text('Sisa kuota: ${e['available_quota'] ?? e['quota'] ?? 0}', style: const TextStyle(fontSize: 12)),
                  if (isOwner) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EventFormPage(event: e)),
                            );
                            if (result == true) loadData();
                          },
                          child: const Text('Edit'),
                        ),
                        TextButton(
                          onPressed: () => deleteEvent(e['id']),
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
