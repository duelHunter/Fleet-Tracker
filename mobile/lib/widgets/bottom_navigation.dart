import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Highlight the active tab
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return; // Avoid unnecessary navigation
        // Handle navigation
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/map');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
