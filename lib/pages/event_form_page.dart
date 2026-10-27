import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/event_item.dart';
import '../model/model_utils.dart';
import '../service/api.dart';
import '../service/event_service.dart';
import '../utils/pilih_gambar.dart';
import '../widgets/info_banner.dart';

class EventFormPage extends StatefulWidget {
  final EventItem? event;

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _hargaController = TextEditingController(text: '0');
  final _kuotaController = TextEditingController();

  DateTime? _tanggal;
  TimeOfDay _jam = const TimeOfDay(hour: 19, minute: 0);
  Uint8List? _bannerBytes;
  String? _bannerName;

  bool _loading = false;
  String? _error;
  String? _errorTanggal;

  bool get _modeEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    if (event != null) {
      _judulController.text = event.title;
      _deskripsiController.text = event.description;
      _lokasiController.text = event.location;
      _hargaController.text = event.price.round().toString();
      _kuotaController.text = event.quota.toString();

      final tanggal = parseTanggal(event.date);
      if (tanggal != null) {
        _tanggal = DateTime(tanggal.year, tanggal.month, tanggal.day);
        _jam = TimeOfDay(hour: tanggal.hour, minute: tanggal.minute);
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _kuotaController.dispose();
    super.dispose();
  }

  String? _validasiJudul(String? value) {
    final judul = (value ?? '').trim();
    if (judul.isEmpty) return 'Judul event wajib diisi';
    if (judul.length < 3) return 'Judul minimal 3 karakter';
    if (judul.length > 150) return 'Judul maksimal 150 karakter';
    return null;
  }

  String? _validasiDeskripsi(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Deskripsi wajib diisi';
    return null;
  }

  String? _validasiLokasi(String? value) {
    final lokasi = (value ?? '').trim();
    if (lokasi.isEmpty) return 'Lokasi wajib diisi';
    if (lokasi.length > 255) return 'Lokasi maksimal 255 karakter';
    return null;
  }

  String? _validasiHarga(String? value) {
    final teks = (value ?? '').trim();
    if (teks.isEmpty) return 'Harga wajib diisi';
    final harga = int.tryParse(teks);
    if (harga == null) return 'Harga harus berupa angka';
    if (harga < 0) return 'Harga tidak boleh negatif';
    return null;
  }

  String? _validasiKuota(String? value) {
    final teks = (value ?? '').trim();
    if (teks.isEmpty) return 'Kuota wajib diisi';
    final kuota = int.tryParse(teks);
    if (kuota == null) return 'Kuota harus berupa angka';
    if (kuota < 1) return 'Kuota minimal 1';
    return null;
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final awal = DateTime(sekarang.year, sekarang.month, sekarang.day);
    var terpilih = _tanggal ?? sekarang.add(const Duration(days: 7));
    if (terpilih.isBefore(awal)) terpilih = awal;

    final hasil = await showDatePicker(
      context: context,
      initialDate: terpilih,
      firstDate: awal,
      lastDate: DateTime(sekarang.year + 5, 12, 31),
      helpText: 'Pilih tanggal event',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (hasil != null && mounted) {
      setState(() {
        _tanggal = hasil;
        _errorTanggal = null;
      });
    }
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(
      context: context,
      initialTime: _jam,
      helpText: 'Pilih jam event',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (hasil != null && mounted) {
      setState(() => _jam = hasil);
    }
  }

  Future<void> _pilihBanner() async {
    try {
      final gambar = await pilihGambarDariGaleri();
      if (gambar == null || !mounted) return;

      setState(() {
        _bannerBytes = gambar.bytes;
        _bannerName = gambar.nama;
      });
    } on PilihGambarException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal memilih gambar. Coba lagi.');
    }
  }

  Future<void> _simpan() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    final formValid = _formKey.currentState?.validate() ?? false;
    final tanggalKosong = _tanggal == null;

    if (tanggalKosong) {
      setState(() => _errorTanggal = 'Tanggal event wajib dipilih');
    }

    if (!formValid || tanggalKosong) return;

    final tanggalLengkap = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jam.hour,
      _jam.minute,
    );

    if (!_modeEdit && !tanggalLengkap.isAfter(DateTime.now())) {
      setState(() {
        _error = 'Tanggal dan jam event harus di masa depan.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final fields = <String, String>{
      'title': _judulController.text.trim(),
      'description': _deskripsiController.text.trim(),
      'date': tanggalLengkap.toIso8601String(),
      'location': _lokasiController.text.trim(),
      'price': _hargaController.text.trim(),
      'quota': _kuotaController.text.trim(),
    };

    try {
      final response = _modeEdit
          ? await EventService.update(
              id: widget.event!.id,
              fields: fields,
              bannerBytes: _bannerBytes,
              bannerName: _bannerName,
            )
          : await EventService.create(
              fields: fields,
              bannerBytes: _bannerBytes,
              bannerName: _bannerName,
            );

      if (!mounted) return;

      final body = readMap(response);
      final pesan = readText(
        body['message'],
        _modeEdit ? 'Event berhasil diperbarui.' : 'Event berhasil dibuat.',
      );

      _snack(pesan);
      Navigator.pop(context, true);
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
        _error = 'Gagal menyimpan event. Silakan coba lagi.';
      });
    }
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  String get _tanggalTeks {
    if (_tanggal == null) return 'Pilih tanggal';
    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ][_tanggal!.month - 1];
    return '${_tanggal!.day} $bulan ${_tanggal!.year}';
  }

  String get _jamTeks {
    final jam = _jam.hour.toString().padLeft(2, '0');
    final menit = _jam.minute.toString().padLeft(2, '0');
    return '$jam.$menit';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit event' : 'Buat event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text('Banner event', style: tema.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Opsional. Gunakan gambar JPG atau PNG maksimal 5 MB.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _PratinjauBanner(
              bytes: _bannerBytes,
              url: widget.event?.bannerUrl,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pilihBanner,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(
                    _bannerBytes == null ? 'Pilih dari galeri' : 'Ganti gambar',
                  ),
                ),
                if (_bannerBytes != null) ...[
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _bannerBytes = null;
                              _bannerName = null;
                            });
                          },
                    child: const Text('Batalkan pilihan'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 22),
            const _LabelBagian('Informasi event'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _judulController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: _validasiJudul,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'Judul event',
                hintText: 'Contoh: Jakarta Music Fest 2026',
                prefixIcon: Icon(Icons.local_activity_outlined, size: 20),
                counterText: '',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _deskripsiController,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              validator: _validasiDeskripsi,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Ceritakan konsep, lineup, atau informasi penting.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lokasiController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: _validasiLokasi,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                hintText: 'Contoh: Gelora Bung Karno, Jakarta',
                prefixIcon: Icon(Icons.place_outlined, size: 20),
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            const _LabelBagian('Jadwal & tiket'),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Pemilih(
                    label: 'Tanggal',
                    nilai: _tanggalTeks,
                    ikon: Icons.calendar_today_rounded,
                    onTap: _loading ? null : _pilihTanggal,
                    error: _errorTanggal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Pemilih(
                    label: 'Jam mulai',
                    nilai: _jamTeks,
                    ikon: Icons.schedule_rounded,
                    onTap: _loading ? null : _pilihJam,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hargaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validasiHarga,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _kuotaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validasiKuota,
                    decoration: const InputDecoration(
                      labelText: 'Kuota',
                      hintText: '100',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Isi harga 0 untuk event gratis. Kuota minimal 1 tiket.',
              style: tema.textTheme.bodySmall,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              InfoBanner(
                icon: Icons.error_outline_rounded,
                message: _error!,
                color: AppColors.danger,
                background: AppColors.dangerSoft,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _simpan,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_modeEdit ? 'Simpan perubahan' : 'Buat event'),
          ),
        ),
      ),
    );
  }
}

class _PratinjauBanner extends StatelessWidget {
  final Uint8List? bytes;
  final String? url;

  const _PratinjauBanner({this.bytes, this.url});

  @override
  Widget build(BuildContext context) {
    Widget isi;

    if (bytes != null) {
      isi = Image.memory(
        bytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (url != null && url!.isNotEmpty) {
      isi = Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const _KosongBanner(),
      );
    } else {
      isi = const _KosongBanner();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 168,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.brandSoft,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isi,
      ),
    );
  }
}

class _KosongBanner extends StatelessWidget {
  const _KosongBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandSoft, Color(0xFFF4E7E7)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 34,
              color: AppColors.brand.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 6),
            Text(
              'Belum ada banner',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelBagian extends StatelessWidget {
  final String teks;

  const _LabelBagian(this.teks);

  @override
  Widget build(BuildContext context) {
    return Text(
      teks.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

class _Pemilih extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData ikon;
  final VoidCallback? onTap;
  final String? error;

  const _Pemilih({
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.onTap,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.surfaceAlt,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            side: BorderSide(
              color: error == null ? AppColors.line : AppColors.danger,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(ikon, size: 18, color: AppColors.brand),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 10.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nilai,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
