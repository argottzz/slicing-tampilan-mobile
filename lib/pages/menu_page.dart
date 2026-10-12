import 'package:flutter/material.dart';
import 'home_page.dart';
import 'today_page.dart';
import 'inbox_page.dart';
import 'profile_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int index = 0;

  List<Widget> pages = [
    HomePage(),
    TodayPage(),
    InboxPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    var navy = Color(0xFF101E33);
    var hijau = Color(0xFF8DEE9C);
    var abuHint = Color(0xFFB9B3A8);

    bool tampilFab = index == 0 || index == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: pages[index],
      ),
      floatingActionButton: tampilFab
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: hijau,
              foregroundColor: navy,
              shape: CircleBorder(),
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: navy,
        unselectedItemColor: abuHint,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
