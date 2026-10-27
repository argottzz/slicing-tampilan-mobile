import 'package:flutter/foundation.dart';

const String _apiUrlOverride = String.fromEnvironment('API_URL');

/// Alamat backend yang dipakai aplikasi.
///
/// `--dart-define=API_URL=...` selalu menang. Tanpa override:
/// - Android memakai `10.0.2.2` (alias localhost untuk emulator Android).
/// - Web, Windows, macOS, Linux, dan iOS memakai `localhost`.
///
/// HP Android fisik tetap perlu `--dart-define=API_URL=...` karena
/// `10.0.2.2` hanya berlaku di emulator.
String get apiBaseUrl {
  if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api';
  }

  return 'http://localhost:8000/api';
}

const Duration apiTimeout = Duration(seconds: 20);

const List<String> _bulanPendek = [
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
];

const List<String> _hari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

DateTime? parseTanggal(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return DateTime.tryParse(raw.trim());
}

String formatTanggal(String? raw, {bool pakaiJam = true}) {
  final tanggal = parseTanggal(raw);
  if (tanggal == null) return '-';

  final hari = _hari[tanggal.weekday - 1];
  final bulan = _bulanPendek[tanggal.month - 1];
  final dasar = '$hari, ${tanggal.day} $bulan ${tanggal.year}';

  if (!pakaiJam) return dasar;

  final jam = tanggal.hour.toString().padLeft(2, '0');
  final menit = tanggal.minute.toString().padLeft(2, '0');
  return '$dasar • $jam.$menit';
}

String formatTanggalPendek(String? raw) {
  final tanggal = parseTanggal(raw);
  if (tanggal == null) return '-';
  final bulan = _bulanPendek[tanggal.month - 1];
  return '${tanggal.day} $bulan ${tanggal.year}';
}

String formatRupiah(num nilai) {
  final angka = nilai.round();
  if (angka == 0) return 'Gratis';

  final teks = angka.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < teks.length; i++) {
    if (i > 0 && (teks.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(teks[i]);
  }

  return '${angka < 0 ? '-' : ''}Rp$buffer';
}

String labelStatus(String status) {
  switch (status) {
    case 'pending':
      return 'Menunggu';
    case 'approved':
      return 'Disetujui';
    case 'cancelled':
      return 'Dibatalkan';
    default:
      return status;
  }
}

String pesanStatus(String status) {
  switch (status) {
    case 'pending':
      return 'Menunggu pemeriksaan pembayaran oleh organizer.';
    case 'approved':
      return 'Tiket aktif dan siap digunakan.';
    case 'cancelled':
      return 'Pendaftaran ini sudah dibatalkan.';
    default:
      return '';
  }
}
