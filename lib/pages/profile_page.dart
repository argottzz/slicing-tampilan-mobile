import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/app_user.dart';
import '../service/api.dart';
import '../service/auth_service.dart';
import '../widgets/brand_mark.dart';
import '../widgets/initials_avatar.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onUserChanged;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onUserChanged,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loadingEdit = false;
  bool _loadingOrganizer = false;

  Future<void> _editNama() async {
    if (_loadingEdit) return;

    final formKey = GlobalKey<FormState>();
    var nama = widget.user.name;

    final hasil = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit nama'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: widget.user.name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (value) => nama = value,
              validator: (value) {
                final teks = (value ?? '').trim();
                if (teks.isEmpty) return 'Nama wajib diisi';
                if (teks.length < 3) return 'Nama minimal 3 karakter';
                if (teks.length > 100) return 'Nama maksimal 100 karakter';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, nama.trim());
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (hasil == null || !mounted) return;
    if (hasil == widget.user.name) return;

    setState(() => _loadingEdit = true);

    try {
      final user = await AuthService.updateName(hasil);
      if (!mounted) return;
      widget.onUserChanged(user);
      _snack('Nama berhasil diperbarui.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal memperbarui nama.');
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  Future<void> _jadiOrganizer() async {
    if (_loadingOrganizer) return;

    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jadi organizer?'),
          content: const Text(
            'Akunmu akan diubah menjadi organizer. Kamu bisa membuat event, '
            'mengunggah banner, dan mengelola peserta. Tindakan ini tidak '
            'mengubah tiket yang sudah kamu miliki.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Jadi organizer'),
            ),
          ],
        );
      },
    );

    if (setuju != true || !mounted) return;

    setState(() => _loadingOrganizer = true);

    try {
      final hasil = await AuthService.becomeOrganizer();
      await ApiService.saveToken(hasil.token);

      if (!mounted) return;
      widget.onUserChanged(hasil.user);
      _snack('Akunmu sekarang organizer. Menu Kelola sudah tersedia.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _snack(error.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal mengubah akun menjadi organizer.');
    } finally {
      if (mounted) setState(() => _loadingOrganizer = false);
    }
  }

  Future<void> _logout() async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Kamu perlu login kembali untuk mengakses tiket dan event.',
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
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (setuju == true) widget.onLogout();
  }

  void _tentang() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              BrandMark(size: 30),
              SizedBox(width: 10),
              Text('Tentang'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GATIX adalah aplikasi mobile event ticketing untuk menjelajah '
                'event, memesan tiket, mengunggah bukti pembayaran, dan '
                'mengelola event sebagai organizer.',
              ),
              const SizedBox(height: 12),
              Text(
                'Versi 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'API: $apiBaseUrl',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final user = widget.user;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text('Profil', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 3),
          Text(
            'Atur akun dan akses organizer-mu.',
            style: tema.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.brandLine),
            ),
            child: Row(
              children: [
                InitialsAvatar(name: user.name, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: tema.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: tema.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _BadgeRole(organizer: user.isOrganizer),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Pengaturan akun', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.line),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Edit nama'),
                  subtitle: Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _loadingEdit
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: _loadingEdit ? null : _editNama,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                if (!user.isOrganizer)
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: const Text('Jadi organizer'),
                    subtitle: const Text('Buat dan kelola event sendiri'),
                    trailing: _loadingOrganizer
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: _loadingOrganizer ? null : _jadiOrganizer,
                  )
                else
                  const ListTile(
                    leading: Icon(
                      Icons.verified_outlined,
                      color: AppColors.success,
                    ),
                    title: Text('Organizer aktif'),
                    subtitle: Text(
                      'Kamu bisa membuat event dan mengelola peserta.',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Lainnya', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.line),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Tentang GATIX'),
              subtitle: const Text('Informasi aplikasi dan alamat API'),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: _tentang,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Keluar dari akun'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'GATIX • Versi 1.0.0',
              style: tema.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRole extends StatelessWidget {
  final bool organizer;

  const _BadgeRole({required this.organizer});

  @override
  Widget build(BuildContext context) {
    final warna = organizer ? AppColors.success : AppColors.brand;
    final latar = organizer ? AppColors.successSoft : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: warna.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            organizer ? Icons.verified_rounded : Icons.person_rounded,
            size: 12,
            color: warna,
          ),
          const SizedBox(width: 4),
          Text(
            organizer ? 'Organizer' : 'Peserta',
            style: TextStyle(
              color: warna,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
