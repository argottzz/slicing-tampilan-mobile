import 'package:flutter/material.dart';

import '../model/app_user.dart';
import 'home_page.dart';
import 'manage_events_page.dart';
import 'my_tickets_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onUserChanged;
  final VoidCallback onLogout;

  const MainShell({
    super.key,
    required this.user,
    required this.onUserChanged,
    required this.onLogout,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.user.isOrganizer &&
        widget.user.isOrganizer &&
        _index == 2) {
      _index = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final halaman = <Widget>[
      HomePage(user: widget.user),
      MyTicketsPage(
        onExplore: () => setState(() => _index = 0),
      ),
      if (widget.user.isOrganizer) ManageEventsPage(user: widget.user),
      ProfilePage(
        user: widget.user,
        onUserChanged: widget.onUserChanged,
        onLogout: widget.onLogout,
      ),
    ];

    final tujuan = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.confirmation_number_outlined),
        selectedIcon: Icon(Icons.confirmation_number),
        label: 'Tiket',
      ),
      if (widget.user.isOrganizer)
        const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Kelola',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final indexAman = _index.clamp(0, halaman.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: indexAman,
        children: halaman,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE8E0E0))),
        ),
        child: NavigationBar(
          selectedIndex: indexAman,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: tujuan,
        ),
      ),
    );
  }
}
