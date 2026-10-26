import 'package:flutter/material.dart';
import 'package:tugas_slicing/service/api.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  bool loading = true;
  String error = '';
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final res = await ApiService.get('/registrations/my-tickets');
      tickets = res['data'] ?? [];
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
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
    if (tickets.isEmpty) {
      return const Center(child: Text('Belum ada tiket'));
    }
    return RefreshIndicator(
      onRefresh: loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final t = tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(t['event']?['title'] ?? 'Event'),
              subtitle: Text('Status: ${t['status'] ?? '-'}'),
            ),
          );
        },
      ),
    );
  }
}
