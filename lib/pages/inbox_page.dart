import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/menu_widgets.dart';

// Inbox — kartu Aktifitas Login baru (mockup ke-3 screenshot Menu).
// Ditambahkan responsive untuk lebar layar handphone.
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 12.0 : 16.0),
      child: Column(
        children: [
          // Header menu
          MenuHeader(),

          // SizedBox with adaptive height - not const because depends on orientation
          SizedBox(height: isLandscape ? 12.0 : 18.0),

          // Card 1: Notifikasi baru
          _BuildCard(isLandscape: isLandscape),

          SizedBox(height: isLandscape ? 10.0 : 12.0),

          // Card 2: Login dari perangkat baru
          _BuildCard2(isLandscape: isLandscape),
        ],
      ),
    );
  }
}

class _BuildCard extends StatelessWidget {
  final bool isLandscape;
  const _BuildCard({required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    final size = isLandscape ? 40.0 : 44.0;
    final iconSize = isLandscape ? 20.0 : 22.0;
    return Container(
      padding: EdgeInsets.all(isLandscape ? 12.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isLandscape ? 12.0 : 16.0),
        border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications, color: Colors.white, size: iconSize),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aktifitas Login baru',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Lorem Ipsmu dolor is amet for a...',
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildCard2 extends StatelessWidget {
  final bool isLandscape;
  const _BuildCard2({required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    final iconSize = isLandscape ? 20.0 : 20.0;
    return Container(
      padding: EdgeInsets.all(isLandscape ? 12.0 : 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isLandscape ? 12.0 : 16.0),
        border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_outlined,
              size: iconSize, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Login dari perangkat baru',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Hari ini, 08:41 • Jakarta',
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}