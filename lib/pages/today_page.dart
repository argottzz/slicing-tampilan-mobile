import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/menu_widgets.dart';

/// Today — varian list penuh dengan search (mockup ke-2 screenshot Menu).
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: const [
        MenuHeader(),
        SizedBox(height: 12),
        SearchField(),
        SizedBox(height: 14),
        TaskCard(
          title: 'Design Wireframe',
          time: 'Friday 08:00 AM - 09:00 AM',
          dot: AppColors.dotRed,
        ),
        TaskCard(
          title: 'Meet with client',
          time: 'Friday 10:00 AM - 11:00 AM',
          dot: AppColors.dotBlue,
        ),
        TaskCard(
          title: "April's content selection",
          time: 'Friday 01:00 PM - 02:00 PM',
          dot: AppColors.dotBlue,
        ),
        TaskCard(
          title: 'Design Wireframe',
          time: 'Friday 08:00 AM - 09:00 AM',
          dot: AppColors.dotRed,
        ),
        TaskCard(
          title: 'Meet with client',
          time: 'Friday 10:00 AM - 11:00 AM',
          dot: AppColors.dotBlue,
        ),
        TaskCard(
          title: 'Brainstorming session - ideas',
          time: 'Saturday 08:00 AM - 17:00 PM',
          dot: AppColors.dotGreen,
        ),
      ],
    );
  }
}
