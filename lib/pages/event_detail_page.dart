import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/app_user.dart';
import '../model/event_item.dart';
import '../model/ticket.dart';
import '../service/api.dart';
import '../service/event_service.dart';
import '../service/registration_service.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/network_banner.dart';
import '../widgets/state_view.dart';
import 'event_form_page.dart';
import 'participants_page.dart';
import 'ticket_detail_page.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;
  final AppUser user;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.user,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  EventItem? _event;
  Ticket? _tiketSaya;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  bool get _pemilik =>
      _event != null && _event!.createdBy == widget.user.id;

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
      final event = await EventService.detail(widget.eventId);
      Ticket? tiket;

      if (event.createdBy != widget.user.id) {
        try {
          final tiketSaya = await RegistrationService.myTickets();
          for (final item in tiketSaya) {
            if (item.eventId == widget.eventId && !item.cancelled) {
              tiket = item;
              break;
            }
          }
        } catch (_) {
          tiket = null;
        }
      }

      if (!mounted) return;
      setState(() {
        _event = event;
        _tiketSaya = tiket;
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
        _error = 'Gagal memuat detail event.';
      });
    }
  }

  Future<void> _daftar() async {
    final event = _event;
    if (event == null || _busy) return;

    if (!event.gratis) {
      final lanjut = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Daftar event berbayar?'),
            content: Text(
              'Setelah mendaftar, kamu perlu mengunggah bukti pembayaran '
              '${formatRupiah(event.price)} dari halaman Tiket Saya.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lanjut daftar'),
              ),
            ],
          );
        },
      );
      if (lanjut != true) return;
    }

    setState(() => _busy = true);

    try {
      final tiket = await RegistrationService.create(event.id);
      if (!mounted) return;

      _snack(
        tiket.approved
            ? 'Pendaftaran berhasil. Tiketmu sudah aktif.'
            : 'Pendaftaran berhasil. Unggah bukti pembayaran di halaman tiket.',
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailPage(registrationId: tiket.id),
        ),
      );

      if (mounted) await _load(diam: true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
      if (error.message.toLowerCase().contains('sudah terdaftar')) {
        await _load(diam: true);
      }
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal mendaftar event. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bukaTiket() async {
    final tiket = _tiketSaya;
    if (tiket == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketDetailPage(registrationId: tiket.id),
      ),
    );

    if (mounted) await _load(diam: true);
  }

  Future<void> _edit() async {
    final event = _event;
    if (event == null) return;

    final berubah = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EventFormPage(event: event)),
    );

    if (berubah == true && mounted) {
      await _load(diam: true);
    }
  }

  Future<void> _hapus() async {
    final event = _event;
    if (event == null || _busy) return;

    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus event?'),
          content: Text(
            'Event "${event.title}" akan dihapus permanen beserta '
            'pendaftaran dan bukti pembayarannya.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (setuju != true || !mounted) return;

    setState(() => _busy = true);

    try {
      await EventService.delete(event.id);
      if (!mounted) return;
      _snack('Event berhasil dihapus.');
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal menghapus event.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bukaPeserta() async {
    final event = _event;
    if (event == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParticipantsPage(
          eventId: event.id,
          eventTitle: event.title,
        ),
      ),
    );

    if (mounted) await _load(diam: true);
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
        appBar: AppBar(title: const Text('Detail event')),
        body: const LoadingState(message: 'Memuat detail event...'),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail event')),
        body: Center(
          child: SingleChildScrollView(
            child: ErrorState(
              message: _error ?? 'Event tidak ditemukan.',
              onRetry: _load,
            ),
          ),
        ),
      );
    }

    final event = _event!;
    final tanggal = parseTanggal(event.date);
    final sudahLewat = tanggal != null && tanggal.isBefore(DateTime.now());

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _BagianBanner(
                  event: event,
                  pemilik: _pemilik,
                  onKembali: () => Navigator.pop(context),
                  onEdit: _edit,
                  onHapus: _hapus,
                ),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                formatRupiah(event.price),
                                style: const TextStyle(
                                  color: AppColors.brand,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _BarisDetail(
                          ikon: Icons.calendar_today_rounded,
                          label: 'Tanggal',
                          nilai: formatTanggal(event.date),
                        ),
                        const SizedBox(height: 14),
                        _BarisDetail(
                          ikon: Icons.place_outlined,
                          label: 'Lokasi',
                          nilai: event.location,
                        ),
                        const SizedBox(height: 18),
                        _KartuKuota(event: event),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              InitialsAvatar(name: event.organizerName, size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Diselenggarakan oleh',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event.organizerName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    if (event.organizerEmail.isNotEmpty)
                                      Text(
                                        event.organizerEmail,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Tentang event',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description.isEmpty
                              ? 'Belum ada deskripsi untuk event ini.'
                              : event.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BilahAksi(
            event: event,
            pemilik: _pemilik,
            tiket: _tiketSaya,
            busy: _busy,
            sudahLewat: sudahLewat,
            onDaftar: _daftar,
            onLihatTiket: _bukaTiket,
            onKelolaPeserta: _bukaPeserta,
          ),
        ],
      ),
    );
  }
}

class _BagianBanner extends StatelessWidget {
  final EventItem event;
  final bool pemilik;
  final VoidCallback onKembali;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const _BagianBanner({
    required this.event,
    required this.pemilik,
    required this.onKembali,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 278,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkBanner(
            url: event.bannerUrl,
            fallbackIcon: Icons.local_activity_outlined,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.42),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.46),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TombolBulat(
                    ikon: Icons.arrow_back_rounded,
                    onTap: onKembali,
                    tooltip: 'Kembali',
                  ),
                  const Spacer(),
                  if (pemilik)
                    PopupMenuButton<String>(
                      tooltip: 'Aksi event',
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'hapus') onHapus();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit event'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'hapus',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                            ),
                            title: Text(
                              'Hapus event',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ),
                        ),
                      ],
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: const Text(
                    'EVENT',
                    style: TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
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

class _TombolBulat extends StatelessWidget {
  final IconData ikon;
  final VoidCallback onTap;
  final String tooltip;

  const _TombolBulat({
    required this.ikon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(ikon, size: 20, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _BarisDetail extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String nilai;

  const _BarisDetail({
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(ikon, size: 18, color: AppColors.brand),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                nilai,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KartuKuota extends StatelessWidget {
  final EventItem event;

  const _KartuKuota({required this.event});

  @override
  Widget build(BuildContext context) {
    final rasio = event.quota <= 0
        ? 0.0
        : (event.taken / event.quota).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 18,
                color: AppColors.brand,
              ),
              const SizedBox(width: 8),
              Text(
                'Sisa kuota',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                '${event.availableQuota} / ${event.quota}',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rasio,
              minHeight: 6,
              backgroundColor: Colors.white,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.kuotaHabis
                ? 'Kuota event sudah habis.'
                : '${event.availableQuota} tiket masih tersedia.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _BilahAksi extends StatelessWidget {
  final EventItem event;
  final bool pemilik;
  final Ticket? tiket;
  final bool busy;
  final bool sudahLewat;
  final VoidCallback onDaftar;
  final VoidCallback onLihatTiket;
  final VoidCallback onKelolaPeserta;

  const _BilahAksi({
    required this.event,
    required this.pemilik,
    required this.tiket,
    required this.busy,
    required this.sudahLewat,
    required this.onDaftar,
    required this.onLihatTiket,
    required this.onKelolaPeserta,
  });

  @override
  Widget build(BuildContext context) {
    Widget tombol;

    if (pemilik) {
      tombol = ElevatedButton.icon(
        onPressed: onKelolaPeserta,
        icon: const Icon(Icons.people_alt_outlined, size: 18),
        label: const Text('Kelola peserta'),
      );
    } else if (tiket != null) {
      tombol = OutlinedButton.icon(
        onPressed: onLihatTiket,
        icon: const Icon(Icons.confirmation_number_outlined, size: 18),
        label: const Text('Lihat tiket saya'),
      );
    } else if (sudahLewat) {
      tombol = const ElevatedButton(
        onPressed: null,
        child: Text('Event sudah berlangsung'),
      );
    } else if (event.kuotaHabis) {
      tombol = const ElevatedButton(
        onPressed: null,
        child: Text('Kuota habis'),
      );
    } else {
      tombol = ElevatedButton(
        onPressed: busy ? null : onDaftar,
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                event.gratis
                    ? 'Daftar sekarang'
                    : 'Daftar • ${formatRupiah(event.price)}',
              ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: tombol,
    );
  }
}
