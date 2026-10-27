import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InitialsAvatar({super.key, required this.name, this.size = 48});

  String get _inisial {
    final bagian = name.trim().split(RegExp(r'\s+'));
    if (bagian.isEmpty || bagian.first.isEmpty) return 'G';
    if (bagian.length == 1) return bagian.first.substring(0, 1).toUpperCase();
    return (bagian.first.substring(0, 1) + bagian.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Text(
        _inisial,
        style: TextStyle(
          color: AppColors.brand,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
