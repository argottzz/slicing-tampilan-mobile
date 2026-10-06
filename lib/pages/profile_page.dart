import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Profile — Alex Gilles (mockup kanan screenshot Menu).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        letterSpacing: 0.4)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 18, color: Colors.black26),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              const CircleAvatar(
                radius: 62,
                backgroundColor: Color(0xFFE8DCC8),
                backgroundImage:
                    AssetImage('assets/higuruma_pp.jpg'),
              ),
              Positioned(
                right: 0,
                bottom: 6,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: const Icon(Icons.edit,
                      size: 14, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Alex Gilles',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: AppColors.inputBorder.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                _infoTile(
                    icon: Icons.phone_outlined,
                    label: 'PHONE',
                    value: '+7 904 599 XXX 11'),
                const Divider(height: 1),
                _infoTile(
                    icon: Icons.mail_outlined,
                    label: 'EMAIL',
                    value: 'alexg@gmail.com'),
                const Divider(height: 1),
                _infoTile(
                    icon: Icons.location_on_outlined,
                    label: 'ADDRESS',
                    value: 'St. Petersburg, Vos...'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
