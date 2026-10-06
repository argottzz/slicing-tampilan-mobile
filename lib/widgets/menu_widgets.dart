import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.inputBorder),
            color: Colors.white,
          ),
          child: const Text('FR',
              style:
                  TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Stack(
                children: const [
                  Icon(Icons.notifications_outlined, size: 20),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: CircleAvatar(
                        radius: 3, backgroundColor: Colors.red),
                  ),
                ],
              ),
              Container(
                height: 16,
                width: 1,
                color: AppColors.inputBorder,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const Icon(Icons.more_horiz, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle:
            const TextStyle(fontSize: 13, color: Colors.black54),
        prefixIcon: const Icon(Icons.search,
            size: 20, color: Colors.black54),
        filled: true,
        fillColor: AppColors.searchBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, size: 18),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final Color dot;
  final bool highlighted;
  const TaskCard({
    super.key,
    required this.title,
    required this.time,
    required this.dot,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.cardPurple : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? null
            : Border.all(color: AppColors.inputBorder.withValues(alpha: 0.6)),
      ),
      child: highlighted
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined,
                      size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('In april\'s content selection...',
                          style: TextStyle(
                              fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: dot, width: 2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 12, color: AppColors.brown),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(time,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.brown)),
                          ),
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.black38),
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
