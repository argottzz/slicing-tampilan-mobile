# GATIX Mobile

Aplikasi mobile **event ticketing** berbasis Flutter yang terhubung langsung ke REST API GATIX. Aplikasi ini dibuat sebagai proyek pembelajaran untuk siswa kelas XI RPL: struktur sederhana, `StatefulWidget`, `setState`, `http`, dan `SharedPreferences` tanpa state management atau arsitektur berlapis yang berlebihan.

## Fitur

### Pengguna
- Registrasi dan login dengan validasi form.
- Sesi login disimpan sebagai token di `SharedPreferences` dan dikirim sebagai `Authorization: Bearer <token>`.
- Validasi sesi ke `GET /auth/me` saat aplikasi dibuka.
- Menjelajah event, mencari kata kunci, memfilter lokasi, dan mengurutkan tanggal/harga.
- Melihat detail event dan sisa kuota.
- Mendaftar event gratis maupun berbayar.
- Melihat daftar tiket dengan filter status.
- Melihat detail tiket, mengunggah/mengganti bukti pembayaran, dan membatalkan tiket.
- Memperbarui nama dan menjadi organizer.
- Logout dengan konfirmasi.

### Organizer
- Membuat event baru, termasuk banner dari galeri.
- Mengedit dan menghapus event miliknya.
- Melihat daftar event yang ia buat.
- Melihat peserta event dan bukti pembayaran.
- Menyetujui atau membatalkan tiket peserta.

## Teknologi
- Flutter 3.44 / Dart 3.12
- `http` + `http_parser` untuk REST API dan multipart upload
- `shared_preferences` untuk token
- `image_picker` untuk memilih gambar dari galeri (Photo Picker Android)

## Struktur Proyek
```text
lib/
├── config/       # base URL API, format tanggal/rupiah, tema
├── model/        # AppUser, EventItem, Ticket
├── pages/        # halaman aplikasi
├── service/      # ApiService, AuthService, EventService, RegistrationService
├── utils/        # helper pemilihan gambar
├── widgets/      # komponen UI yang dipakai ulang
└── main.dart     # entry point dan AuthGate
```

## Menjalankan Aplikasi

### 1. Siapkan backend
Backend GATIX berada di proyek terpisah (`projectWeb/backend`). Nyalakan MySQL, lalu jalankan:

```bash
npm install
npm run dev
```

Pastikan `http://localhost:8000/api/health` mengembalikan `{"status":"ok"}`.

### 2. Install dependency Flutter
```bash
flutter pub get
```

### 3. Pilih base URL

**Emulator Android** (default, tanpa `--dart-define`):
```bash
flutter run
```
Default: `http://10.0.2.2:8000/api`

**HP fisik via USB** (paling mudah, tidak perlu satu jaringan Wi-Fi):
```bash
adb reverse tcp:8000 tcp:8000
flutter run -d <device-id> --dart-define=API_URL=http://127.0.0.1:8000/api
```
`adb reverse` meneruskan `localhost:8000` di HP ke backend laptop. Jalankan ulang perintah `adb reverse` setiap kali HP dicabut/di-reconnect.

**HP fisik via Wi-Fi** (ganti dengan IP LAN komputer):
```bash
flutter run --dart-define=API_URL=http://192.168.1.10:8000/api
```
HP dan komputer harus berada di jaringan yang sama. Backend harus listen di `0.0.0.0` (bukan hanya `localhost`).

**Chrome / web** (port 3000 agar sesuai CORS backend):
```bash
flutter run -d chrome --web-port=3000
```
Tanpa `--dart-define`, web/desktop otomatis memakai `http://localhost:8000/api`. Jangan membuka aplikasi lewat `http://127.0.0.1:3000` dan jangan memakai `--web-hostname=127.0.0.1`, karena CORS backend hanya mengizinkan origin `http://localhost:3000`.

### Jika muncul "Koneksi ke server terlalu lama"
1. Pastikan backend hidup: `http://localhost:8000/api/health` mengembalikan `{"status":"ok"}`.
2. Perhatikan alamat API di pesan error atau di bagian bawah tab **Profil**:
   - Web/desktop: `http://localhost:8000/api`
   - Emulator Android: `http://10.0.2.2:8000/api`
   - HP fisik via USB: `http://127.0.0.1:8000/api` setelah `adb reverse tcp:8000 tcp:8000`
3. Di Chrome, pastikan aplikasi berjalan di port **3000** dan dibuka lewat `localhost`, bukan `127.0.0.1`.
4. Di HP fisik, jalankan ulang `adb reverse` setiap kali kabel dicabut atau HP disambungkan ulang.

## Akun Uji
Tidak ada akun bawaan. Buat akun melalui halaman **Daftar**, lalu:
1. Login.
2. Masuk ke tab **Profil**.
3. Pilih **Jadi organizer** untuk membuka tab **Kelola**.
4. Buat event pertama dari tab **Kelola**.

## Endpoint yang Digunakan
| Fitur | Method & Endpoint |
|---|---|
| Register | `POST /auth/register` |
| Login | `POST /auth/login` |
| Sesi saat ini | `GET /auth/me` |
| Ubah nama | `PATCH /auth/me` |
| Jadi organizer | `POST /auth/become-organizer` |
| Jelajah event | `GET /events` |
| Detail event | `GET /events/:id` |
| Buat event | `POST /events` (multipart, `banner`) |
| Edit event | `PATCH /events/:id` (multipart, `banner`) |
| Hapus event | `DELETE /events/:id` |
| Daftar event | `POST /registrations` |
| Tiket saya | `GET /registrations/my-tickets` |
| Detail tiket | `GET /registrations/:id` |
| Unggah bukti | `PATCH /registrations/:id/payment` (multipart, `payment_proof`) |
| Ubah status tiket | `PATCH /registrations/:id/status` |
| Peserta event | `GET /events/:id/registrations` |

## Pengujian

### Pemeriksaan statis, unit test, dan build Android
```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Integration test UI di Chrome
Test ini menjalankan aplikasi Flutter asli di Chrome dan terhubung ke backend lokal. Test membuat akun peserta, akun organizer, tiga event, serta satu tiket berbayar beserta bukti pembayaran; data uji tersebut tetap tersimpan di database setelah test selesai.

Prasyarat:
1. Backend berjalan di `http://localhost:8000/api`.
2. Chrome dan chromedriver versi yang cocok tersedia. Jalankan chromedriver di port 4444.
3. Port 3000 bebas dan CORS backend mengizinkan `http://localhost:3000`.

```bash
chromedriver --port=4444
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome --web-port=3000 --web-hostname=localhost
```
Perintah di atas sengaja tidak memakai `--dart-define` agar sekaligus memverifikasi default web/desktop `http://localhost:8000/api`.

Jika `flutter drive` gagal dengan `AppConnectionException` saat menunggu debug service Chrome, verifikasi manual lewat `flutter run -d chrome --web-port=3000`. Kegagalan tersebut terjadi pada debug service Chrome, bukan pada API.

Cakupan integration test:
- Login peserta, pencarian event, pendaftaran event gratis, konfirmasi pendaftaran event berbayar, tiket pending, filter tiket, pembatalan tiket dengan konfirmasi, dan logout.
- Login organizer, membuka event miliknya, melihat bukti pembayaran, menyetujui peserta, mengedit judul event, menghapus event dengan konfirmasi, serta memverifikasi status persetujuan dan penghapusan lewat API.

Hasil pengujian terakhir pada mesin pengembangan:
| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | Tidak ada issue |
| `flutter test` | 6/6 lulus |
| `flutter build web --release` | Berhasil |
| `flutter run -d chrome` + login manual | Berhasil: token tersimpan dan Beranda memuat event |
| `flutter drive` (Chrome) | 2/2 lulus pada uji sebelumnya; percobaan ulang 28 Okt 2026 gagal connect debug Chrome (`AppConnectionException`) |
| `flutter build apk --debug` | Berhasil |
| `flutter run` di HP Android | Berhasil: login, Beranda, dan Tiket Saya tampil dengan data backend |

Pengujian API manual juga dilakukan langsung ke backend lokal untuk register/login, profil, menjadi organizer, CRUD event dan banner, pendaftaran gratis/berbayar, unggah bukti, pembatalan tiket, daftar/approve peserta, filter/pencarian, serta respons 401/403.

## Batasan yang Diketahui
- Backend tidak menyediakan endpoint logout atau refresh token. Logout hanya menghapus token di perangkat; token tetap valid sampai masa berlakunya habis.
- Backend tidak menyediakan endpoint “event milik organizer”. Aplikasi mengambil daftar event (maksimal 50 per halaman) lalu memfilter `created_by` di sisi klien.
- Unggah gambar dibatasi backend: JPG/PNG, maksimal 5 MB.
- Base URL pengembangan memakai HTTP. `usesCleartextTraffic` di Android hanya untuk pengembangan lokal; produksi harus memakai HTTPS.
- Token disimpan di `SharedPreferences`, bukan secure storage. Untuk produksi, gunakan penyimpanan terenkripsi.
- Pemilihan gambar hanya dari galeri (bukan kamera).
- Tanggal dari backend dikirim sebagai waktu lokal tanpa zona waktu; aplikasi menampilkannya apa adanya.
- Belum ada fitur lupa password karena backend belum menyediakannya.
- Integration test belum mengotomatiskan pemilih gambar galeri, pembuatan event dari form lengkap dengan pemilih tanggal/waktu, dan pemasangan banner; alur API-nya sudah diuji manual, tetapi interaksi UI tersebut perlu diuji pada perangkat.
- Emulator Android tidak dapat dijalankan pada mesin pengembangan karena keterbatasan RAM/commit memory Windows. Aplikasi sudah dijalankan di HP fisik Android 11 (21061119AG) melalui `adb reverse` dan berhasil login serta menampilkan event/tiket dari backend; perangkat iOS dan emulator Android belum diuji.
- Pada 28 Oktober 2026, `flutter drive` di Chrome gagal pada tahap koneksi debug service (`AppConnectionException`) walaupun `flutter run -d chrome` dan login manual berhasil. Kegagalan ini berasal dari harness Flutter Web/Chrome di mesin pengembangan, bukan dari endpoint backend; integration test dapat dijalankan ulang saat harness stabil.

## Catatan Keamanan
- Jangan commit file `.env` atau kredensial backend.
- Untuk HP fisik atau backend di mesin lain, tentukan `API_URL` melalui `--dart-define`; jangan hardcode IP pribadi ke dalam kode. Web/desktop otomatis memakai `localhost`.
- Untuk produksi, gunakan HTTPS, secure storage, dan endpoint logout/refresh token dari backend.
