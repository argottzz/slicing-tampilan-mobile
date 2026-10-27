import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tugas_slicing/config/api_config.dart';
import 'package:tugas_slicing/main.dart' as app;
import 'package:tugas_slicing/service/api.dart';
import 'package:tugas_slicing/widgets/event_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const sandi = 'e2e-rahasia-123';
  const namaPeserta = 'E2E Peserta';
  const namaOrganizer = 'E2E Organizer';

  late String emailPeserta;
  late String emailOrganizer;
  late String tokenOrganizer;
  late String judulBerbayar;
  late String judulBerbayarDua;
  late String judulGratis;
  late int eventBerbayarId;
  late int registrasiBerbayarId;

  setUpAll(() async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    emailPeserta = 'e2e.peserta.$stamp@example.com';
    emailOrganizer = 'e2e.organizer.$stamp@example.com';
    judulBerbayar = 'E2E Berbayar $stamp';
    judulBerbayarDua = 'E2E Berbayar Dua $stamp';
    judulGratis = 'E2E Gratis $stamp';

    final peserta = await _json(
      'POST',
      '/auth/register',
      body: {
        'name': namaPeserta,
        'email': emailPeserta,
        'password': sandi,
      },
    );
    final pesertaToken = peserta['token'] as String;

    final organizer = await _json(
      'POST',
      '/auth/register',
      body: {
        'name': namaOrganizer,
        'email': emailOrganizer,
        'password': sandi,
      },
    );
    tokenOrganizer = organizer['token'] as String;

    final menjadiOrganizer = await _json(
      'POST',
      '/auth/become-organizer',
      body: const {},
      token: tokenOrganizer,
    );
    tokenOrganizer = menjadiOrganizer['token'] as String;

    final berbayar = await _buatEvent(tokenOrganizer, {
      'title': judulBerbayar,
      'description': 'Event berbayar untuk pengujian integrasi GATIX.',
      'date': _tanggal(30),
      'location': 'Jakarta E2E Hall',
      'price': '50000',
      'quota': '20',
    });
    eventBerbayarId = (berbayar['id'] as num).toInt();

    await _buatEvent(tokenOrganizer, {
      'title': judulBerbayarDua,
      'description': 'Event berbayar kedua untuk menguji alur pendaftaran.',
      'date': _tanggal(45),
      'location': 'Bandung E2E Hall',
      'price': '75000',
      'quota': '20',
    });

    await _buatEvent(tokenOrganizer, {
      'title': judulGratis,
      'description': 'Event gratis untuk menguji tiket otomatis aktif.',
      'date': _tanggal(20),
      'location': 'Jakarta E2E Park',
      'price': '0',
      'quota': '30',
    });

    final registrasi = await _json(
      'POST',
      '/registrations',
      body: {'event_id': eventBerbayarId},
      token: pesertaToken,
    );
    registrasiBerbayarId = (registrasi['data']['id'] as num).toInt();
    await _unggahBukti(pesertaToken, registrasiBerbayarId);
  });

  setUp(() async {
    await ApiService.clearToken();
  });

  tearDownAll(() async {
    await ApiService.clearToken();
  });

  testWidgets('peserta login, daftar event, filter tiket, dan logout', (
    tester,
  ) async {
    app.main();

    await _login(tester, emailPeserta);
    await _bukaEvent(tester, judulGratis);

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Daftar sekarang'),
    );
    await _tunggu(tester, find.text('Detail tiket'));
    await _tunggu(
      tester,
      find.textContaining('Tiket aktif dan siap digunakan'),
    );

    await tester.pageBack();
    await _tunggu(tester, find.byTooltip('Kembali'));
    await _kembaliKeBeranda(tester);

    await _bukaEvent(tester, judulBerbayarDua);
    await _tungguHilang(tester, find.byType(SnackBar));
    final tombolDaftar = _tombolDaftarBerbayar();
    await _tunggu(tester, tombolDaftar);
    await tester.ensureVisible(tombolDaftar);
    await tester.tap(tombolDaftar);
    await _tunggu(tester, find.text('Daftar event berbayar?'));
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Lanjut daftar'),
    );

    await _tunggu(tester, find.text('Detail tiket'));
    await _tunggu(
      tester,
      find.textContaining('Menunggu pemeriksaan'),
    );
    await tester.scrollUntilVisible(
      find.text('Pilih bukti pembayaran'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pilih bukti pembayaran'), findsOneWidget);

    await tester.pageBack();
    await _tunggu(tester, find.byTooltip('Kembali'));
    await _kembaliKeBeranda(tester);

    await tester.tap(find.text('Tiket'));
    await _tunggu(tester, find.text('Tiket saya'));

    final filterDisetujui = find
        .ancestor(
          of: find.text('Disetujui'),
          matching: find.byType(InkWell),
        )
        .first;
    await tester.tap(filterDisetujui);
    await _tunggu(tester, find.text(judulGratis));
    expect(find.text(judulBerbayar), findsNothing);

    final filterMenunggu = find
        .ancestor(
          of: find.text('Menunggu'),
          matching: find.byType(InkWell),
        )
        .first;
    await tester.tap(filterMenunggu);
    await _tunggu(tester, find.text(judulBerbayarDua));
    await tester.scrollUntilVisible(
      find.text(judulBerbayar),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(judulGratis), findsNothing);

    await tester.tap(find.text('Profil'));
    await _tunggu(tester, find.text(namaPeserta));

    final tombolKeluar = find.text('Keluar dari akun');
    await tester.scrollUntilVisible(
      tombolKeluar,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tombolKeluar);
    await _tunggu(tester, find.text('Keluar dari akun?'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
    await _tunggu(tester, find.text('Masuk ke akun'));
  });

  testWidgets('organizer melihat bukti dan menyetujui peserta', (
    tester,
  ) async {
    app.main();

    await _login(tester, emailOrganizer);
    await tester.tap(find.text('Kelola'));
    await _tunggu(tester, find.text('Kelola event'));

    await tester.scrollUntilVisible(
      find.text(judulBerbayar),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(judulBerbayar));
    await _tunggu(tester, find.byTooltip('Kembali'));

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Kelola peserta'),
    );
    await _tunggu(tester, find.text('Peserta event'));

    await tester.scrollUntilVisible(
      find.text(namaPeserta),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Lihat bukti pembayaran'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Lihat bukti pembayaran'));
    await _tunggu(tester, find.byTooltip('Tutup'));
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pump(const Duration(milliseconds: 300));

    final tombolSetujui = find.widgetWithText(ElevatedButton, 'Setujui');
    await tester.ensureVisible(tombolSetujui);
    await tester.tap(tombolSetujui);
    await _tunggu(tester, find.text('Setujui tiket?'));
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Setujui'),
      ),
    );

    await _tunggu(
      tester,
      find.text('Menunggu (0)'),
      batas: const Duration(seconds: 20),
    );

    final hasil = await _json(
      'GET',
      '/events/$eventBerbayarId/registrations',
      token: tokenOrganizer,
    );
    final daftar = (hasil['data'] as List).cast<Map<String, dynamic>>();
    final tiket = daftar.firstWhere(
      (item) => item['id'] == registrasiBerbayarId,
    );
    expect(tiket['status'], 'approved');
  });
}

Future<void> _login(WidgetTester tester, String email) async {
  await _tunggu(tester, find.text('Masuk ke akun'));

  final kolom = find.byType(TextFormField);
  expect(kolom, findsNWidgets(2));
  await tester.enterText(kolom.at(0), email);
  await tester.enterText(kolom.at(1), 'e2e-rahasia-123');

  final tombol = find.widgetWithText(ElevatedButton, 'Masuk');
  await tester.ensureVisible(tombol);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(tombol);
  await _tunggu(tester, find.text('Mau ke event apa hari ini?'));
}

Future<void> _bukaEvent(WidgetTester tester, String judul) async {
  final kolomCari = find.byType(TextField).first;
  await _tunggu(tester, kolomCari);
  await tester.ensureVisible(kolomCari);
  await tester.tap(kolomCari);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.enterText(kolomCari, '');
  await tester.pump(const Duration(milliseconds: 100));
  await tester.enterText(kolomCari, judul);

  final target = find.descendant(
    of: find.byType(EventCard),
    matching: find.text(judul),
  );
  await _tunggu(tester, target);
  final satu = target.first;
  await tester.ensureVisible(satu);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(satu);
  await _tunggu(tester, find.byTooltip('Kembali'));
}

Future<void> _kembaliKeBeranda(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Kembali'));
  await _tunggu(tester, find.byType(NavigationBar));
}

Finder _tombolDaftarBerbayar() {
  return find.byWidgetPredicate((widget) {
    if (widget is! ElevatedButton) return false;
    final child = widget.child;
    return child is Text && (child.data ?? '').startsWith('Daftar');
  });
}

Future<void> _tungguHilang(
  WidgetTester tester,
  Finder finder, {
  Duration batas = const Duration(seconds: 10),
}) async {
  final akhir = DateTime.now().add(batas);

  while (DateTime.now().isBefore(akhir)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isEmpty) return;
  }

  fail('Masih menemukan $finder setelah ${batas.inSeconds} detik.');
}

Future<void> _tunggu(
  WidgetTester tester,
  Finder finder, {
  Duration batas = const Duration(seconds: 30),
}) async {
  final akhir = DateTime.now().add(batas);

  while (DateTime.now().isBefore(akhir)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 150));
      return;
    }
  }

  final teks = find
      .byType(Text)
      .evaluate()
      .map((element) => (element.widget as Text).data)
      .whereType<String>()
      .take(40)
      .join(' | ');
  fail(
    'Tidak menemukan $finder dalam ${batas.inSeconds} detik. '
    'Teks di layar: $teks',
  );
}

String _tanggal(int hariKe) {
  final tanggal = DateTime.now().add(Duration(days: hariKe));
  String dua(int nilai) => nilai.toString().padLeft(2, '0');
  return '${tanggal.year}-${dua(tanggal.month)}-${dua(tanggal.day)}T19:00:00';
}

Future<Map<String, dynamic>> _json(
  String method,
  String path, {
  Map<String, dynamic>? body,
  String? token,
}) async {
  final uri = Uri.parse('$apiBaseUrl$path');
  final headers = <String, String>{'Content-Type': 'application/json'};
  if (token != null) headers['Authorization'] = 'Bearer $token';

  late http.Response response;

  if (method == 'GET') {
    response = await http.get(uri, headers: headers);
  } else if (method == 'POST') {
    response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
  } else if (method == 'PATCH') {
    response = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
  } else {
    throw ArgumentError('Method $method belum didukung.');
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      '$method $path gagal (${response.statusCode}): ${response.body}',
    );
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _buatEvent(
  String token,
  Map<String, String> fields,
) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$apiBaseUrl/events'),
  );
  request.headers['Authorization'] = 'Bearer $token';
  request.fields.addAll(fields);

  final response = await http.Response.fromStream(await request.send());
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Gagal membuat event (${response.statusCode}): ${response.body}');
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return body['data'] as Map<String, dynamic>;
}

Future<void> _unggahBukti(String token, int registrationId) async {
  final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8'
    '/x8AAusB9Y9Zl9sAAAAASUVORK5CYII=',
  );

  final request = http.MultipartRequest(
    'PATCH',
    Uri.parse('$apiBaseUrl/registrations/$registrationId/payment'),
  );
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(
    http.MultipartFile.fromBytes(
      'payment_proof',
      bytes,
      filename: 'bukti-e2e.png',
      contentType: MediaType('image', 'png'),
    ),
  );

  final response = await http.Response.fromStream(await request.send());
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Gagal mengunggah bukti (${response.statusCode}): ${response.body}');
  }
}

