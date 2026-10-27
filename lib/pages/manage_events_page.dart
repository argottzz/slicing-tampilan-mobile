import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/app_user.dart';
import '../model/event_item.dart';
import '../service/api.dart';
import '../service/event_service.dart';
import '../widgets/network_banner.dart';
import '../widgets/state_view.dart';
import 'event_detail_page.dart';
import 'event_form_page.dart';
import 'participants_page.dart';

class ManageEventsPage extends StatefulWidget {
  final AppUser user;

  const ManageEventsPage({super.key, required this.user});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  final List<EventItem> _events = [];
  bool _loading = true;
  String? _error;

  int get _totalPendaftar =>
      _events.fold(0, (jumlah, event) => jumlah + event.taken);

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
      final hasil = await EventService.mine(widget.user.id);
      if (!mounted) return;
      setState(() {
        _events
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
        _error = 'Gagal memuat daftar event. Silakan coba lagi.';
      });
    }
  }

  Future<void> _buatEvent() async {
    final berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EventFormPage()),
    );

    if (berhasil == true && mounted) await _load();
  }

  Future<void> _bukaDetail(EventItem event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailPage(
          eventId: event.id,
          user: widget.user,
        ),
      ),
    );

    if (mounted) await _load();
  }

  Future<void> _kelolaPeserta(EventItem event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParticipantsPage(
          eventId: event.id,
          eventTitle: event.title,
        ),
      ),
    );

    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

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
                      Text('Kelola event', style: tema.textTheme.headlineSmall),
                      const SizedBox(height: 3),
                      Text(
                        'Buat event, atur peserta, dan perbarui informasi.',
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
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
                    '${_events.length} event',
                    style: const TextStyle(
                      color: AppColors.brand,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Statistik(
                      label: 'Event dikelola',
                      nilai: '${_events.length}',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: AppColors.line,
                  ),
                  Expanded(
                    child: _Statistik(
                      label: 'Total pendaftar',
                      nilai: '$_totalPendaftar',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _buatEvent,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Buat event baru'),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading && _events.isEmpty)
              const SizedBox(height: 300, child: LoadingState())
            else if (_error != null)
              ErrorState(message: _error!, onRetry: _load)
            else if (_events.isEmpty)
              EmptyState(
                icon: Icons.dashboard_customize_outlined,
                title: 'Belum ada event',
                message:
                    'Buat event pertamamu agar bisa mulai menerima pendaftaran.',
                actionLabel: 'Buat event',
                onAction: _buatEvent,
              )
            else ...[
              Text('Event milikmu', style: tema.textTheme.titleLarge),
              const SizedBox(height: 10),
              for (final event in _events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KartuKelola(
                    event: event,
                    onTap: () => _bukaDetail(event),
                    onPeserta: () => _kelolaPeserta(event),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Statistik extends StatelessWidget {
  final String label;
  final String nilai;

  const _Statistik({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          nilai,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _KartuKelola extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;
  final VoidCallback onPeserta;

  const _KartuKelola({
    required this.event,
    required this.onTap,
    required this.onPeserta,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final rasio = event.quota <= 0
        ? 0.0
        : (event.taken / event.quota).clamp(0.0, 1.0);

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 86,
                      height: 86,
                      child: NetworkBanner(
                        url: event.bannerUrl,
                        fallbackIcon: Icons.local_activity_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                formatTanggal(event.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tema.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 12,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tema.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Text(
                              formatRupiah(event.price),
                              style: const TextStyle(
                                color: AppColors.brand,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${event.taken}/${event.quota}',
                              style: tema.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: rasio,
                  minHeight: 4,
                  backgroundColor: AppColors.brandSoft,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onPeserta,
                    icon: const Icon(Icons.people_alt_outlined, size: 16),
                    label: const Text('Kelola peserta'),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
