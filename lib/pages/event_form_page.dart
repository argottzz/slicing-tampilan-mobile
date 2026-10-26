import 'package:flutter/material.dart';
import 'package:tugas_slicing/service/api.dart';

class EventFormPage extends StatefulWidget {
  final Map<String, dynamic>? event; // null = create, else edit
  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final quotaController = TextEditingController();

  DateTime? selectedDate;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    if (e != null) {
      titleController.text = e['title'] ?? '';
      descController.text = e['description'] ?? '';
      locationController.text = e['location'] ?? '';
      priceController.text = (e['price'] ?? 0).toString();
      quotaController.text = (e['quota'] ?? 1).toString();
      if (e['date'] != null) {
        selectedDate = DateTime.tryParse(e['date'].toString());
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    locationController.dispose();
    priceController.dispose();
    quotaController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        quotaController.text.trim().isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final data = {
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'date': selectedDate!.toIso8601String(),
        'location': locationController.text.trim(),
        'price': double.tryParse(priceController.text) ?? 0,
        'quota': int.tryParse(quotaController.text) ?? 1,
      };

      if (widget.event == null) {
        await ApiService.post('/events', data);
      } else {
        await ApiService.put('/events/${widget.event!['id']}', data);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Event' : 'Tambah Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Pilih tanggal'
                        : selectedDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
                ElevatedButton(onPressed: pickDate, child: const Text('Pilih Tanggal')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quotaController,
              decoration: const InputDecoration(labelText: 'Kuota'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'Simpan' : 'Tambah'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
