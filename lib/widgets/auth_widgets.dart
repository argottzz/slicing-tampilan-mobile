import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Logo daun Leafboard: lingkaran putih + icon daun 2 warna.
class LeafLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  const LeafLogo({super.key, this.size = 72, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.eco, size: size * 0.55, color: AppColors.leafGreenDark),
          Positioned(
            right: size * 0.28,
            bottom: size * 0.26,
            child: Icon(Icons.eco,
                size: size * 0.38, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}

/// Ikon Google digambar ulang (tanpa package tambahan).
class GoogleGIcon extends StatelessWidget {
  final double size;
  const GoogleGIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.20;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, s - stroke, s - stroke);

    Paint strokePaint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Lingkaran penuh dibagi 4 warna khas Google.
    canvas.drawArc(rect, -0.5, 1.35, false,
        strokePaint(const Color(0xFF4285F4)));
    canvas.drawArc(rect, 0.85, 1.10, false,
        strokePaint(const Color(0xFF34A853)));
    canvas.drawArc(rect, 1.95, 1.60, false,
        strokePaint(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, 3.55, 2.23, false,
        strokePaint(const Color(0xFFEA4335)));

    // Palang horizontal G.
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2,
        size.height / 2 - stroke / 2,
        size.width / 2 - stroke / 2,
        stroke,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Header kecil dipakai di Login / Register.
class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, this.subtitle = 'Work without limits'});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.eco, size: 26, color: AppColors.leafGreenDark),
                Positioned(
                  right: 2,
                  bottom: 1,
                  child: Icon(Icons.eco, size: 17, color: AppColors.navy),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Text(
              'Leafboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}

InputDecoration authInputDecoration({
  required String hint,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: AppColors.inputHint),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    filled: true,
    fillColor: Colors.white,
    suffixIcon: suffix,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: AppColors.leafGreenDark),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}

class AuthLabel extends StatelessWidget {
  final String text;
  const AuthLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );
  }
}

/// Tombol Continue pil penuh, abu saat disabled & hijau saat enabled.
/// Teks center, chevron rata kanan seperti desain.
class ContinueButton extends StatelessWidget {
  final bool enabled;
  final String text;
  final VoidCallback? onPressed;
  const ContinueButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.text = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? AppColors.leafGreen : AppColors.disabledBg,
          foregroundColor:
              enabled ? Colors.black87 : AppColors.disabledText,
          disabledBackgroundColor: AppColors.disabledBg,
          disabledForegroundColor: AppColors.disabledText,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const Positioned(
              right: 18,
              child: Icon(Icons.chevron_right, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.inputBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: TextStyle(fontSize: 12, color: AppColors.inputHint)),
        ),
        Expanded(child: Divider(color: AppColors.inputBorder)),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.inputBorder),
          foregroundColor: Colors.black87,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
