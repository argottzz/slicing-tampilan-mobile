import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final warna = _warna(status);
    final latar = _latar(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: warna.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            labelStatus(status),
            style: TextStyle(
              color: warna,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _warna(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Color _latar(String status) {
    switch (status) {
      case 'approved':
        return AppColors.successSoft;
      case 'cancelled':
        return AppColors.dangerSoft;
      default:
        return AppColors.warningSoft;
    }
  }
}
