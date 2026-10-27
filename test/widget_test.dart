import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_slicing/config/api_config.dart';
import 'package:tugas_slicing/config/app_theme.dart';
import 'package:tugas_slicing/widgets/status_badge.dart';

void main() {
  group('formatRupiah', () {
    test('menampilkan Gratis untuk harga 0', () {
      expect(formatRupiah(0), 'Gratis');
    });

    test('memberi pemisah ribuan', () {
      expect(formatRupiah(50000), 'Rp50.000');
      expect(formatRupiah(1250000), 'Rp1.250.000');
    });
  });

  group('formatTanggal', () {
    test('memformat tanggal MySQL dengan nama hari Indonesia', () {
      expect(
        formatTanggal('2026-10-10 19:30:00'),
        'Sabtu, 10 Okt 2026 • 19.30',
      );
    });

    test('memakai tanda hubung untuk tanggal kosong atau tidak valid', () {
      expect(formatTanggal(null), '-');
      expect(formatTanggal('bukan tanggal'), '-');
    });
  });

  testWidgets('StatusBadge menampilkan label yang mudah dibaca', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const Scaffold(
          body: StatusBadge(status: 'approved'),
        ),
      ),
    );

    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
  });
}
