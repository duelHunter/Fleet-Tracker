import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/screens/map_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
// import 'package:mobile/screens/websocket_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:web_socket_channel/io.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerOneOffTask("continuous_location", "track_location");
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "track_location") {
      await startLocationTracking();
    }
    return Future.value(true);
  });
}

Future<void> startLocationTracking() async {
  l.Location location = l.Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;
  }

  var permissionStatus = await Permission.locationAlways.status;
  if (!permissionStatus.isGranted) {
    await Permission.locationAlways.request();
    return;
  }

  IOWebSocketChannel? channel;
  bool isConnected = false;

  void connectWebSocket() async {
    try {
      channel = IOWebSocketChannel.connect("ws://34.46.215.218:8080/ws");
      isConnected = true;
      print("✅ WebSocket connected successfully");

      channel?.stream.listen(
        (message) {
          print("📩 Received from server: $message");
        },
        onError: (error) {
          print("❌ WebSocket Error: $error");
          isConnected = false;
        },
        onDone: () {
          print("🔌 WebSocket closed.");
          isConnected = false;
        },
      );
    } catch (e) {
      print("❌ WebSocket connection failed: $e");
    }
  }

  connectWebSocket();

  location.onLocationChanged.listen((l.LocationData event) {
    print("Hiii");
    double latitude = event.latitude ?? 0.0;
    double longitude = event.longitude ?? 0.0;
    double speed = event.speed ?? 0.0;

    Map<String, dynamic> locationDataMap = {
      "latitude": latitude,
      "longitude": longitude,
      "speed": speed,
      "timestamp": DateTime.now().toIso8601String(),
    };

    print("📍 Background Location: $locationDataMap");

    if (isConnected) {
      try {
        channel?.sink.add(jsonEncode(locationDataMap));
        print("📡 Sent location: $locationDataMap");
      } catch (e) {
        print("❌ Failed to send location: $e");
      }
    }
  });
}

//////////////////////////////////////////////////////
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
