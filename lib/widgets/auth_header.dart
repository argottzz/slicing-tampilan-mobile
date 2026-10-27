import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import 'brand_mark.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandDark, AppColors.brand],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -54,
            top: -58,
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: -46,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(light: true, size: 38),
                const SizedBox(height: 26),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: const [
                    _Perks(ikon: Icons.local_activity_outlined, teks: 'Tiket digital'),
                    _Perks(ikon: Icons.verified_outlined, teks: 'Status transparan'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Perks extends StatelessWidget {
  final IconData ikon;
  final String teks;

  const _Perks({required this.ikon, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 14, color: Colors.white.withValues(alpha: 0.62)),
        const SizedBox(width: 5),
        Text(
          teks,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}
