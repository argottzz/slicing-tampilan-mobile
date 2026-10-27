import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../model/ticket.dart';
import '../service/api.dart';
import '../service/registration_service.dart';
import '../widgets/state_view.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_page.dart';

class MyTicketsPage extends StatefulWidget {
  final VoidCallback onExplore;

  const MyTicketsPage({super.key, required this.onExplore});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final List<Ticket> _tickets = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final hasil = await RegistrationService.myTickets();
      if (!mounted) return;
      setState(() {
        _tickets
          ..clear()
          ..addAll(hasil);
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat tiket. Silakan coba lagi.';
      });
    }
  }

  int _jumlah(String status) {
    if (status == 'all') return _tickets.length;
    return _tickets.where((ticket) => ticket.status == status).length;
  }

  List<Ticket> get _tampil {
    if (_filter == 'all') return _tickets;
    return _tickets.where((ticket) => ticket.status == _filter).toList();
  }

  String get _pesanKosong {
    switch (_filter) {
      case 'pending':
        return 'Tidak ada tiket yang menunggu pembayaran.';
      case 'approved':
        return 'Belum ada tiket yang disetujui.';
      case 'cancelled':
        return 'Tidak ada tiket yang dibatalkan.';
      default:
        return 'Kamu belum mendaftar event apa pun.';
    }
  }

  Future<void> _bukaTiket(Ticket ticket) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketDetailPage(registrationId: ticket.id),
      ),
    );

    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final daftar = _tampil;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tiket saya', style: tema.textTheme.headlineSmall),
                      const SizedBox(height: 3),
                      Text(
                        'Pantau status pembayaran dan tiket aktifmu.',
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.brandLine),
                  ),
                  child: Text(
                    '${_tickets.length} tiket',
                    style: const TextStyle(
                      color: AppColors.brand,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    jumlah: _jumlah('all'),
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Menunggu',
                    jumlah: _jumlah('pending'),
                    selected: _filter == 'pending',
                    onTap: () => setState(() => _filter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Disetujui',
                    jumlah: _jumlah('approved'),
                    selected: _filter == 'approved',
                    onTap: () => setState(() => _filter = 'approved'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dibatalkan',
                    jumlah: _jumlah('cancelled'),
                    selected: _filter == 'cancelled',
                    onTap: () => setState(() => _filter = 'cancelled'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_loading && _tickets.isEmpty)
              const SizedBox(height: 320, child: LoadingState())
            else if (_error != null)
              ErrorState(message: _error!, onRetry: _load)
            else if (daftar.isEmpty)
              EmptyState(
                icon: Icons.confirmation_number_outlined,
                title: _filter == 'all'
                    ? 'Belum ada tiket'
                    : 'Tiket tidak ditemukan',
                message: _pesanKosong,
                actionLabel: _filter == 'all' ? 'Jelajah event' : null,
                onAction: _filter == 'all' ? widget.onExplore : null,
              )
            else ...[
              for (final ticket in daftar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TicketCard(
                    ticket: ticket,
                    onTap: () => _bukaTiket(ticket),
                  ),
                ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Tiket diperbarui saat halaman ini dibuka ulang.',
                  style: tema.textTheme.bodySmall?.copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int jumlah;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.jumlah,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? AppColors.brand : AppColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.18)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$jumlah',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
