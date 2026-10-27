import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../model/app_user.dart';
import '../model/event_item.dart';
import '../service/api.dart';
import '../service/event_service.dart';
import '../widgets/event_card.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/state_view.dart';
import 'event_detail_page.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  final List<EventItem> _events = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  String _search = '';
  String _location = '';
  String _sortBy = 'date';
  String _order = 'asc';

  int _page = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String get _labelUrutan {
    if (_sortBy == 'price') {
      return _order == 'asc' ? 'Harga termurah' : 'Harga termahal';
    }
    return _order == 'asc' ? 'Terdekat' : 'Terbaru';
  }

  bool get _adaFilter =>
      _search.isNotEmpty || _location.isNotEmpty || _sortBy != 'date' || _order != 'asc';

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _events.clear();
      });
    } else {
      if (_loadingMore || _page >= _totalPages) return;
      setState(() => _loadingMore = true);
    }

    try {
      final hasil = await EventService.list(
        search: _search,
        location: _location,
        sortBy: _sortBy,
        order: _order,
        page: reset ? 1 : _page + 1,
        limit: 12,
      );

      if (!mounted) return;
      setState(() {
        if (reset) _events.clear();
        _events.addAll(hasil.items);
        _page = hasil.page;
        _totalPages = hasil.totalPages;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (reset) {
        setState(() => _error = error.message);
      } else {
        _snack(error.message);
      }
    } catch (_) {
      if (!mounted) return;
      if (reset) {
        setState(() => _error = 'Gagal memuat event.');
      } else {
        _snack('Gagal memuat event.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value.trim());
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _load(reset: true);
    });
  }

  void _cariSekarang() {
    _debounce?.cancel();
    _load(reset: true);
  }

  void _hapusPencarian() {
    _searchController.clear();
    setState(() => _search = '');
    _load(reset: true);
  }

  Future<void> _pilihLokasi() async {
    var nilai = _location;
    final hasil = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter lokasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Masukkan nama kota atau lokasi event.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (value) => nilai = value,
                onSubmitted: (value) => Navigator.pop(context, value.trim()),
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  hintText: 'Contoh: Jakarta',
                  prefixIcon: Icon(Icons.place_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, ''),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, nilai.trim());
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (hasil == null || !mounted) return;

    setState(() => _location = hasil);
    _load(reset: true);
  }

  Future<void> _pilihUrutan() async {
    final hasil = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        final opsi = <_OpsiUrutan>[
          const _OpsiUrutan('date', 'asc', 'Terdekat', 'Tanggal paling dekat'),
          const _OpsiUrutan('date', 'desc', 'Terbaru', 'Tanggal paling akhir'),
          const _OpsiUrutan('price', 'asc', 'Harga termurah', 'Harga kecil ke besar'),
          const _OpsiUrutan('price', 'desc', 'Harga termahal', 'Harga besar ke kecil'),
        ];
        final terpilih = '${_sortBy}_$_order';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urutkan event',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final opsi in opsi)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(opsi.label),
                    subtitle: Text(opsi.keterangan),
                    trailing: terpilih == '${opsi.sortBy}_${opsi.order}'
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.brand,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: AppColors.line,
                          ),
                    onTap: () {
                      Navigator.pop(context, '${opsi.sortBy}_${opsi.order}');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (hasil == null || !mounted) return;
    final bagian = hasil.split('_');
    setState(() {
      _sortBy = bagian.first;
      _order = bagian.last;
    });
    _load(reset: true);
  }

  void _resetFilter() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _search = '';
      _location = '';
      _sortBy = 'date';
      _order = 'asc';
    });
    _load(reset: true);
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Future<void> _bukaDetail(EventItem event) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailPage(
          eventId: event.id,
          user: widget.user,
        ),
      ),
    );

    if (mounted) {
      _load(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final namaDepan = widget.user.name.trim().split(RegExp(r'\s+')).first;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, $namaDepan', style: tema.textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        'Mau ke event apa hari ini?',
                        style: tema.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InitialsAvatar(name: widget.user.name, size: 44),
              ],
            ),
            const SizedBox(height: 16),
            _HeroPencarian(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _cariSekarang(),
              onClear: _search.isEmpty ? null : _hapusPencarian,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TombolFilter(
                    icon: Icons.place_outlined,
                    label: _location.isEmpty ? 'Semua lokasi' : _location,
                    active: _location.isNotEmpty,
                    onTap: _pilihLokasi,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TombolFilter(
                    icon: Icons.swap_vert_rounded,
                    label: _labelUrutan,
                    active: _sortBy != 'date' || _order != 'asc',
                    onTap: _pilihUrutan,
                  ),
                ),
              ],
            ),
            if (_adaFilter) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _resetFilter,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reset filter'),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  _adaFilter ? 'Hasil pencarian' : 'Event mendatang',
                  style: tema.textTheme.titleLarge,
                ),
                const Spacer(),
                if (!_loading && _error == null)
                  Text(
                    '${_events.length} event',
                    style: tema.textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(height: 300, child: LoadingState())
            else if (_error != null)
              ErrorState(
                message: _error!,
                onRetry: () => _load(reset: true),
              )
            else if (_events.isEmpty)
              EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'Belum ada event',
                message: _adaFilter
                    ? 'Coba ubah kata kunci atau filter yang kamu pakai.'
                    : 'Event yang tersedia akan muncul di sini.',
                actionLabel: _adaFilter ? 'Reset filter' : 'Muat ulang',
                onAction: _adaFilter
                    ? _resetFilter
                    : () => _load(reset: true),
              )
            else ...[
              for (final event in _events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: EventCard(
                    event: event,
                    onTap: () => _bukaDetail(event),
                  ),
                ),
              const SizedBox(height: 4),
              if (_page < _totalPages)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loadingMore ? null : () => _load(),
                    child: _loadingMore
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Muat lebih banyak'),
                  ),
                )
              else
                Center(
                  child: Text(
                    'Semua event sudah ditampilkan',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroPencarian extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;

  const _HeroPencarian({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandDark, AppColors.brand],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVENT TICKETING',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Temukan event\nfavoritmu.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cari event, pesan tiket, pantau status pembayaran.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari event atau lokasi...',
                    hintStyle: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13.5,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                    suffixIcon: onClear == null
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: onClear,
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.muted,
                            ),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TombolFilter extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TombolFilter({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.brandSoft : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? AppColors.brandLine : AppColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: active ? AppColors.brand : AppColors.muted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.brand : AppColors.ink,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 17,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpsiUrutan {
  final String sortBy;
  final String order;
  final String label;
  final String keterangan;

  const _OpsiUrutan(this.sortBy, this.order, this.label, this.keterangan);
}
