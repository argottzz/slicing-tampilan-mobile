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

**HP fisik** (ganti dengan IP LAN komputer):
```bash
flutter run --dart-define=API_URL=http://192.168.1.10:8000/api
```
HP dan komputer harus berada di jaringan yang sama. Backend harus listen di `0.0.0.0` (bukan hanya `localhost`).

**Chrome / web** (port 3000 agar sesuai CORS backend):
```bash
flutter run -d chrome --web-port=3000 --dart-define=API_URL=http://localhost:8000/api
```

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
```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Batasan yang Diketahui
- Backend tidak menyediakan endpoint logout atau refresh token. Logout hanya menghapus token di perangkat; token tetap valid sampai masa berlakunya habis.
- Backend tidak menyediakan endpoint “event milik organizer”. Aplikasi mengambil daftar event (maksimal 50 per halaman) lalu memfilter `created_by` di sisi klien.
- Unggah gambar dibatasi backend: JPG/PNG, maksimal 5 MB.
- Base URL pengembangan memakai HTTP. `usesCleartextTraffic` di Android hanya untuk pengembangan lokal; produksi harus memakai HTTPS.
- Token disimpan di `SharedPreferences`, bukan secure storage. Untuk produksi, gunakan penyimpanan terenkripsi.
- Pemilihan gambar hanya dari galeri (bukan kamera).
- Tanggal dari backend dikirim sebagai waktu lokal tanpa zona waktu; aplikasi menampilkannya apa adanya.
- Belum ada fitur lupa password karena backend belum menyediakannya.
- Pengujian runtime dilakukan pada emulator Android/Chrome; belum diuji pada iOS atau HP fisik tertentu.

## Catatan Keamanan
- Jangan commit file `.env` atau kredensial backend.
- Ganti `API_URL` melalui `--dart-define`, jangan hardcode IP pribadi ke dalam kode.
- Untuk produksi, gunakan HTTPS, secure storage, dan endpoint logout/refresh token dari backend.
