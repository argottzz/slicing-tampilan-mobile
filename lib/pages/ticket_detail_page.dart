import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/ticket.dart';
import '../service/api.dart';
import '../service/registration_service.dart';
import '../utils/pilih_gambar.dart';
import '../widgets/info_banner.dart';
import '../widgets/network_banner.dart';
import '../widgets/state_view.dart';
import '../widgets/status_badge.dart';

class TicketDetailPage extends StatefulWidget {
  final int registrationId;

  const TicketDetailPage({super.key, required this.registrationId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  Ticket? _ticket;
  bool _loading = true;
  String? _error;

  Uint8List? _buktiBytes;
  String? _buktiName;
  bool _uploading = false;
  bool _membatalkan = false;

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
      final tiket = await RegistrationService.detail(widget.registrationId);
      if (!mounted) return;
      setState(() {
        _ticket = tiket;
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
        _error = 'Gagal memuat tiket. Silakan coba lagi.';
      });
    }
  }

  Future<void> _pilihBukti() async {
    try {
      final gambar = await pilihGambarDariGaleri();
      if (gambar == null || !mounted) return;

      setState(() {
        _buktiBytes = gambar.bytes;
        _buktiName = gambar.nama;
      });
    } on PilihGambarException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal memilih gambar. Coba lagi.');
    }
  }

  Future<void> _unggahBukti() async {
    final bytes = _buktiBytes;
    final nama = _buktiName;

    if (bytes == null || nama == null || _uploading) return;

    setState(() => _uploading = true);

    try {
      await RegistrationService.uploadPaymentProof(
        registrationId: widget.registrationId,
        bytes: bytes,
        fileName: nama,
      );
      if (!mounted) return;

      _snack('Bukti pembayaran berhasil diunggah.');
      setState(() {
        _buktiBytes = null;
        _buktiName = null;
      });
      await _load(diam: true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal mengunggah bukti pembayaran.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _batalkan() async {
    if (_membatalkan) return;

    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan tiket?'),
          content: const Text(
            'Tiket yang dibatalkan tidak bisa dipakai lagi. '
            'Kamu dapat mendaftar ulang selama kuota masih tersedia.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Batalkan tiket'),
            ),
          ],
        );
      },
    );

    if (setuju != true || !mounted) return;

    setState(() => _membatalkan = true);

    try {
      await RegistrationService.cancel(widget.registrationId);
      if (!mounted) return;
      _snack('Tiket berhasil dibatalkan.');
      await _load(diam: true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal membatalkan tiket.');
    } finally {
      if (mounted) setState(() => _membatalkan = false);
    }
  }

  void _lihatBukti(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Gagal memuat bukti pembayaran.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail tiket')),
        body: const LoadingState(message: 'Memuat tiket...'),
      );
    }

    if (_error != null || _ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail tiket')),
        body: Center(
          child: SingleChildScrollView(
            child: ErrorState(
              message: _error ?? 'Tiket tidak ditemukan.',
              onRetry: _load,
            ),
          ),
        ),
      );
    }

    final tiket = _ticket!;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail tiket')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _KartuTiket(tiket: tiket),
            const SizedBox(height: 14),
            _PesanStatus(tiket: tiket),
            const SizedBox(height: 22),
            Text('Informasi tiket', style: tema.textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  _BarisInfo(label: 'Harga', nilai: formatRupiah(tiket.price)),
                  const Divider(height: 1, indent: 14, endIndent: 14),
                  _BarisInfo(
                    label: 'Tanggal',
                    nilai: formatTanggal(tiket.date),
                  ),
                  const Divider(height: 1, indent: 14, endIndent: 14),
                  _BarisInfo(label: 'Lokasi', nilai: tiket.location),
                  const Divider(height: 1, indent: 14, endIndent: 14),
                  _BarisInfo(
                    label: 'ID pendaftaran',
                    nilai: '#${tiket.id}',
                  ),
                ],
              ),
            ),
            if (!tiket.cancelled) ...[
              const SizedBox(height: 22),
              Text('Bukti pembayaran', style: tema.textTheme.titleMedium),
              const SizedBox(height: 10),
              _bagianPembayaran(tiket),
            ],
            if (!tiket.cancelled) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _membatalkan ? null : _batalkan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  icon: _membatalkan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.danger,
                          ),
                        )
                      : const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(
                    _membatalkan ? 'Membatalkan...' : 'Batalkan tiket',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Status tiket hanya dapat diubah oleh organizer event.',
              style: tema.textTheme.bodySmall?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bagianPembayaran(Ticket tiket) {
    final tema = Theme.of(context);
    final adaBukti = tiket.paymentProofUrl != null;
    final pending = tiket.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (adaBukti) ...[
          _GambarBukti(
            url: tiket.paymentProofUrl!,
            onTap: () => _lihatBukti(tiket.paymentProofUrl!),
          ),
          const SizedBox(height: 10),
        ],
        if (pending) ...[
          Text(
            'Unggah bukti transfer agar organizer dapat memverifikasi '
            'pembayaranmu. Format JPG atau PNG, maksimal 5 MB.',
            style: tema.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          if (_buktiBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                _buktiBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _pilihBukti,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Ganti'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploading ? null : _unggahBukti,
                    child: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Unggah bukti'),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploading ? null : _pilihBukti,
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: Text(
                  adaBukti ? 'Ganti bukti pembayaran' : 'Pilih bukti pembayaran',
                ),
              ),
            ),
        ] else if (tiket.approved && !adaBukti)
          const InfoBanner(
            icon: Icons.verified_outlined,
            message:
                'Tiket sudah disetujui. Tidak ada bukti pembayaran yang perlu diunggah.',
            color: AppColors.success,
            background: AppColors.successSoft,
          ),
      ],
    );
  }
}

class _KartuTiket extends StatelessWidget {
  final Ticket tiket;

  const _KartuTiket({required this.tiket});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 146,
            width: double.infinity,
            child: NetworkBanner(
              url: tiket.bannerUrl,
              fallbackIcon: Icons.local_activity_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tiket.title,
                        style: tema.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusBadge(status: tiket.status),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        formatTanggal(tiket.date),
                        style: tema.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tiket.location,
                        style: tema.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Tiket #${tiket.id}',
                      style: tema.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatRupiah(tiket.price),
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PesanStatus extends StatelessWidget {
  final Ticket tiket;

  const _PesanStatus({required this.tiket});

  @override
  Widget build(BuildContext context) {
    if (tiket.approved) {
      return InfoBanner(
        icon: Icons.verified_outlined,
        message: 'Tiket aktif. ${pesanStatus(tiket.status)}',
        color: AppColors.success,
        background: AppColors.successSoft,
      );
    }

    if (tiket.cancelled) {
      return InfoBanner(
        icon: Icons.cancel_outlined,
        message: pesanStatus(tiket.status),
        color: AppColors.danger,
        background: AppColors.dangerSoft,
      );
    }

    return InfoBanner(
      icon: Icons.schedule_rounded,
      message: pesanStatus(tiket.status),
      color: AppColors.warning,
      background: AppColors.warningSoft,
    );
  }
}

class _GambarBukti extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _GambarBukti({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: 176,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Gagal memuat gambar.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_in_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Perbesar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;

  const _BarisInfo({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
