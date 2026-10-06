import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/menu_widgets.dart';

/// Inbox — kartu Aktifitas Login baru (mockup ke-3 screenshot Menu).
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        children: [
          const MenuHeader(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.inputBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC9A44A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aktifitas Login baru',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Lorem Ipsmu dolor is amet for a...',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.brown)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.inputBorder.withValues(alpha: 0.6)),
            ),
            child: const Row(
              children: [
                Icon(Icons.login, size: 20, color: Colors.black54),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Login dari perangkat baru',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Hari ini, 08:41 • Jakarta',
                          style: TextStyle(
                              fontSize: 11, color: Colors.black54)),
                    ],
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
