import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class NetworkBanner extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final IconData fallbackIcon;

  const NetworkBanner({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final gambar = url;

    if (gambar == null || gambar.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      gambar,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(loading: true);
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandSoft, Color(0xFFF4E7E7)],
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brand,
                ),
              )
            : Icon(
                fallbackIcon,
                size: 40,
                color: AppColors.brand.withValues(alpha: 0.35),
              ),
      ),
    );
  }
}
