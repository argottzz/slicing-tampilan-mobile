import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../model/event_item.dart';
import 'network_banner.dart';

class EventCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 156,
                  width: double.infinity,
                  child: NetworkBanner(url: event.bannerUrl),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _Pil(
                    teks: event.gratis ? 'Gratis' : formatRupiah(event.price),
                    warnaTeks: AppColors.brand,
                    warnaLatar: Colors.white,
                  ),
                ),
                if (event.kuotaHabis)
                  const Positioned(
                    right: 12,
                    top: 12,
                    child: _Pil(
                      teks: 'Kuota habis',
                      warnaTeks: AppColors.danger,
                      warnaLatar: AppColors.dangerSoft,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _BarisInfo(
                    ikon: Icons.calendar_today_rounded,
                    teks: formatTanggal(event.date),
                  ),
                  const SizedBox(height: 5),
                  _BarisInfo(
                    ikon: Icons.place_outlined,
                    teks: event.location,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: event.quota <= 0
                          ? 0
                          : (event.taken / event.quota).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: AppColors.brandSoft,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Tersisa ${event.availableQuota} dari ${event.quota} tiket',
                        style: tema.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                      const Spacer(),
                      const Text(
                        'Lihat detail',
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
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  final IconData ikon;
  final String teks;

  const _BarisInfo({required this.ikon, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikon, size: 14, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            teks,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Pil extends StatelessWidget {
  final String teks;
  final Color warnaTeks;
  final Color warnaLatar;

  const _Pil({
    required this.teks,
    required this.warnaTeks,
    required this.warnaLatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        teks,
        style: TextStyle(
          color: warnaTeks,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
