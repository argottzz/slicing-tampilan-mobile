import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/menu_widgets.dart';

/// Home — Morning Ralph + Today(3) + 30 Apr(1) (mockup kiri screenshot Menu).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MenuHeader(),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Morning, Ralph',
              style:
                  TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text('Apryl 27, 2026',
                style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 14),
          const SearchField(),
          const SizedBox(height: 16),
          const SectionHeader('Today (3)'),
          const SizedBox(height: 10),
          const TaskCard(
            title: 'Design Wireframe',
            time: 'Friday 08:00 AM - 09:00 AM',
            dot: AppColors.dotRed,
          ),
          const TaskCard(
            title: 'Meet with client',
            time: 'Friday 10:00 AM - 11:00 AM',
            dot: AppColors.dotBlue,
          ),
          const TaskCard(
            title: "April's content selection",
            time: 'Friday 01:00 PM - 02:00 PM',
            dot: AppColors.dotBlue,
          ),
          const SizedBox(height: 8),
          const SectionHeader('30 Apr (1)'),
          const SizedBox(height: 10),
          const TaskCard(
            title: 'Brainstorming session - ideas',
            time: 'Saturday 08:00 AM - 17:00 PM',
            dot: AppColors.dotGreen,
          ),
        ],
      ),
    );
  }
}
