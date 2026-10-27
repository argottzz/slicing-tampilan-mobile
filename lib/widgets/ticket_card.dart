import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/ticket.dart';
import 'network_banner.dart';
import 'status_badge.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 78,
                      height: 78,
                      child: NetworkBanner(
                        url: ticket.bannerUrl,
                        fallbackIcon: Icons.local_activity_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatTanggal(ticket.date),
                          style: tema.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.location,
                          style: tema.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatRupiah(ticket.price),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _GarisPutus(),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusBadge(status: ticket.status),
                  const Spacer(),
                  const Text(
                    'Lihat tiket',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.brand,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarisPutus extends StatelessWidget {
  const _GarisPutus();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _TitikPutusPainter(AppColors.line)),
    );
  }
}

class _TitikPutusPainter extends CustomPainter {
  final Color color;

  const _TitikPutusPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint()
      ..color = color
      ..strokeWidth = 1;

    const lebar = 5.0;
    const jarak = 5.0;

    for (var x = 0.0; x < size.width; x += lebar + jarak) {
      canvas.drawLine(Offset(x, 0), Offset(x + lebar, 0), cat);
    }
  }

  @override
  bool shouldRepaint(covariant _TitikPutusPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
