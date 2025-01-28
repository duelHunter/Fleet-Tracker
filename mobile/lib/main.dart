import 'package:flutter/material.dart';
import 'package:mobile/screens/map_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
