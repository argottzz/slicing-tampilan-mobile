import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final bool light;

  const BrandMark({super.key, this.size = 40, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: light
                ? Colors.white.withValues(alpha: 0.14)
                : AppColors.brand,
            borderRadius: BorderRadius.circular(size * 0.3),
            border: light
                ? Border.all(color: Colors.white.withValues(alpha: 0.18))
                : null,
          ),
          child: Icon(
            Icons.local_activity_outlined,
            size: size * 0.54,
            color: Colors.white,
          ),
        ),
        SizedBox(width: size * 0.28),
        Text(
          'GATIX',
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: light ? Colors.white : AppColors.ink,
          ),
        ),
      ],
    );
  }
}
