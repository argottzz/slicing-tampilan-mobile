import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/model_utils.dart';
import '../model/ticket.dart';
import '../service/api.dart';
import '../service/event_service.dart';
import '../service/registration_service.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/proof_viewer.dart';
import '../widgets/state_view.dart';
import '../widgets/status_badge.dart';

class ParticipantsPage extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const ParticipantsPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  final List<Ticket> _peserta = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';

  int? _prosesId;
  String? _prosesAksi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool diam = false}) async {
    if (!diam) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final hasil = await EventService.participants(widget.eventId);
      if (!mounted) return;
      setState(() {
        _peserta
          ..clear()
          ..addAll(hasil);
        _loading = false;
        _error = null;
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
        _error = 'Gagal memuat peserta. Silakan coba lagi.';
      });
    }
  }

  int _jumlah(String status) {
    if (status == 'all') return _peserta.length;
    return _peserta.where((tiket) => tiket.status == status).length;
  }

  List<Ticket> get _tampil {
    if (_filter == 'all') return _peserta;
    return _peserta.where((tiket) => tiket.status == _filter).toList();
  }

  String get _pesanKosong {
    switch (_filter) {
      case 'pending':
        return 'Tidak ada peserta yang menunggu verifikasi.';
      case 'approved':
        return 'Belum ada peserta yang disetujui.';
      case 'cancelled':
        return 'Tidak ada peserta yang dibatalkan.';
      default:
        return 'Event ini belum menerima pendaftaran.';
    }
  }

  Future<void> _ubahStatus(Ticket tiket, String status) async {
    if (_prosesId != null) return;

    final menyetujui = status == 'approved';
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(menyetujui ? 'Setujui tiket?' : 'Batalkan tiket?'),
          content: Text(
            menyetujui
                ? (tiket.paymentProofUrl == null
                    ? 'Peserta belum mengunggah bukti pembayaran. '
                        'Tetap setujui tiket ${tiket.userName}?'
                    : 'Pastikan bukti pembayaran ${tiket.userName} sudah '
                        'sesuai. Tiket akan berstatus disetujui.')
                : 'Tiket ${tiket.userName} akan dibatalkan dan tidak bisa '
                    'dipakai lagi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: menyetujui
                  ? null
                  : ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(menyetujui ? 'Setujui' : 'Batalkan'),
            ),
          ],
        );
      },
    );

    if (setuju != true || !mounted) return;

    setState(() {
      _prosesId = tiket.id;
      _prosesAksi = status;
    });

    try {
      final response = await RegistrationService.updateStatus(
        tiket.id,
        status,
      );
      if (!mounted) return;

      final body = readMap(response);
      _snack(readText(
        body['message'],
        menyetujui
            ? 'Tiket peserta berhasil disetujui.'
            : 'Tiket peserta berhasil dibatalkan.',
      ));
      await _load(diam: true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal mengubah status peserta.');
    } finally {
      if (mounted) {
        setState(() {
          _prosesId = null;
          _prosesAksi = null;
        });
      }
    }
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final daftar = _tampil;

    return Scaffold(
      appBar: AppBar(title: const Text('Peserta event')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Text(
              widget.eventTitle,
              style: tema.textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              'Verifikasi pembayaran dan kelola status peserta.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Ringkasan(
                      label: 'Menunggu',
                      nilai: _jumlah('pending'),
                      warna: AppColors.warning,
                    ),
                  ),
                  Expanded(
                    child: _Ringkasan(
                      label: 'Disetujui',
                      nilai: _jumlah('approved'),
                      warna: AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _Ringkasan(
                      label: 'Dibatalkan',
                      nilai: _jumlah('cancelled'),
                      warna: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterPeserta(
                    label: 'Semua',
                    jumlah: _jumlah('all'),
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterPeserta(
                    label: 'Menunggu',
                    jumlah: _jumlah('pending'),
                    selected: _filter == 'pending',
                    onTap: () => setState(() => _filter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterPeserta(
                    label: 'Disetujui',
                    jumlah: _jumlah('approved'),
                    selected: _filter == 'approved',
                    onTap: () => setState(() => _filter = 'approved'),
                  ),
                  const SizedBox(width: 8),
                  _FilterPeserta(
                    label: 'Dibatalkan',
                    jumlah: _jumlah('cancelled'),
                    selected: _filter == 'cancelled',
                    onTap: () => setState(() => _filter = 'cancelled'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loading && _peserta.isEmpty)
              const SizedBox(height: 280, child: LoadingState())
            else if (_error != null)
              ErrorState(message: _error!, onRetry: _load)
            else if (daftar.isEmpty)
              EmptyState(
                icon: Icons.people_alt_outlined,
                title: 'Belum ada peserta',
                message: _pesanKosong,
              )
            else
              for (final tiket in daftar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KartuPeserta(
                    tiket: tiket,
                    diproses: _prosesId == tiket.id,
                    aksi: _prosesAksi,
                    nonaktif: _prosesId != null && _prosesId != tiket.id,
                    onSetujui: () => _ubahStatus(tiket, 'approved'),
                    onBatalkan: () => _ubahStatus(tiket, 'cancelled'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _KartuPeserta extends StatelessWidget {
  final Ticket tiket;
  final bool diproses;
  final String? aksi;
  final bool nonaktif;
  final VoidCallback onSetujui;
  final VoidCallback onBatalkan;

  const _KartuPeserta({
    required this.tiket,
    required this.diproses,
    required this.aksi,
    required this.nonaktif,
    required this.onSetujui,
    required this.onBatalkan,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: tiket.userName, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tiket.userName.isEmpty ? 'Peserta' : tiket.userName,
                      style: tema.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tiket.userEmail,
                      style: tema.textTheme.bodySmall?.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${formatRupiah(tiket.price)} • Tiket #${tiket.id}',
                      style: tema.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: tiket.status),
            ],
          ),
          const SizedBox(height: 10),
          if (tiket.paymentProofUrl != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  tampilkanBuktiPembayaran(context, tiket.paymentProofUrl!);
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 17),
                label: const Text('Lihat bukti pembayaran'),
              ),
            )
          else if (tiket.pending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.18),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Peserta belum mengunggah bukti pembayaran.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (tiket.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: diproses || nonaktif ? null : onBatalkan,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: diproses && aksi == 'cancelled'
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.danger,
                            ),
                          )
                        : const Text('Batalkan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: diproses || nonaktif ? null : onSetujui,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: diproses && aksi == 'approved'
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Ringkasan extends StatelessWidget {
  final String label;
  final int nilai;
  final Color warna;

  const _Ringkasan({
    required this.label,
    required this.nilai,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$nilai',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: warna,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
        ),
      ],
    );
  }
}

class _FilterPeserta extends StatelessWidget {
  final String label;
  final int jumlah;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPeserta({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            '$label ($jumlah)',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
