import 'package:flutter/material.dart';
import 'services/location_track_send_service.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/screens/map_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
// import 'package:mobile/screens/websocket_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the background location tracking service
  await LocationTrackingService.initialize();

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
        // '/websocket': (context) => const WebSocketScreen(),
      },
    );
  }
}
