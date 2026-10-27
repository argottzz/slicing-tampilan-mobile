import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class GambarPilihan {
  final Uint8List bytes;
  final String nama;

  const GambarPilihan({required this.bytes, required this.nama});
}

class PilihGambarException implements Exception {
  final String message;

  const PilihGambarException(this.message);

  @override
  String toString() => message;
}

Future<GambarPilihan?> pilihGambarDariGaleri() async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1800,
  );

  if (file == null) return null;

  final nama = file.name.toLowerCase();
  final dikenal = nama.endsWith('.jpg') ||
      nama.endsWith('.jpeg') ||
      nama.endsWith('.png');

  if (!dikenal && nama.contains('.')) {
    throw const PilihGambarException(
      'Pilih gambar dengan format JPG atau PNG.',
    );
  }

  final bytes = await file.readAsBytes();
  if (bytes.length > 5 * 1024 * 1024) {
    throw const PilihGambarException('Ukuran gambar maksimal 5 MB.');
  }

  return GambarPilihan(
    bytes: bytes,
    nama: dikenal
        ? file.name
        : 'gambar_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
}
