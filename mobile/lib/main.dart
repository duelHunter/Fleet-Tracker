import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:web_socket_channel/io.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
//////////////////screens
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/map_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import '../widgets/bottom_navigation.dart';

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

////
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

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username'); // Returns null if not found
  }

  Future<void> connectWebSocket() async {
    try {
      String? driverId = await getUsername(); // Await the username retrieval
      driverId ??= "defaultDriver"; // Provide a fallback value if null

      print("driverId is $driverId");

      channel = IOWebSocketChannel.connect(
          "ws://34.46.215.218:8080/ws?driverId=$driverId");
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
        '/dashboard': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
        // '/websocket': (context) => const WebSocketScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool gpsEnabled = false;
  bool permissionGranted = false;
  l.Location location = l.Location();
  late StreamSubscription subscription;
  bool trackingEnabled = false;

  List<l.LocationData> locations = [];
  double? currentSpeed;

  IOWebSocketChannel? channel;
  bool isConnected = false;

  // Maintain messageList in the state
  List<String> messageList = [];

  @override
  void initState() {
    super.initState();
    checkStatus();
    connectWebSocket();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location and Speed Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LocationTile(
              title: "GPS",
              trailing: gpsEnabled
                  ? const Text("Enabled")
                  : ElevatedButton(
                      onPressed: requestEnableGps,
                      child: const Text("Enable GPS"),
                    ),
            ),
            LocationTile(
              title: "Permission",
              trailing: permissionGranted
                  ? const Text("Granted")
                  : ElevatedButton(
                      onPressed: requestLocationPermission,
                      child: const Text("Request Permission"),
                    ),
            ),
            LocationTile(
              title: "Location Tracking",
              trailing: trackingEnabled
                  ? ElevatedButton(
                      onPressed: stopTracking,
                      child: const Text("Stop"),
                    )
                  : ElevatedButton(
                      onPressed: gpsEnabled && permissionGranted
                          ? startTracking
                          : null,
                      child: const Text("Start"),
                    ),
            ),
            LocationTile(
              title: "Current Speed",
              trailing: currentSpeed != null
                  ? Text("${currentSpeed!.toStringAsFixed(2)} km/h")
                  : const Text("N/A"),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: locations.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(
            //           "Lat: ${locations[index].latitude}, Lon: ${locations[index].longitude}",
            //         ),
            //       );
            //     },
            //   ),
            // )
            Expanded(
              child: ListView.builder(
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messageList[index]), // Show received messages
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  void requestEnableGps() async {
    bool isGpsActive = await location.requestService();
    setState(() => gpsEnabled = isGpsActive);
  }

  void requestLocationPermission() async {
    var status = await Permission.locationAlways.request();
    setState(() => permissionGranted = status.isGranted);
  }

  void checkStatus() async {
    gpsEnabled = await location.serviceEnabled();
    var status = await Permission.locationAlways.status;
    permissionGranted = status.isGranted;
    setState(() {});
  }

  void startTracking() async {
    connectWebSocket();
    subscription = location.onLocationChanged.listen((event) {
      setState(() {
        currentSpeed = event.speed != null ? event.speed! * 3.6 : null;
        locations.insert(0, event);
        // sendLocationData(event);
        startSendingData(event);
      });
    });

    setState(() => trackingEnabled = true);
  }

  void stopTracking() {
    subscription.cancel();
    setState(() {
      trackingEnabled = false;
      currentSpeed = null;
    });
    locations.clear();
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username'); // Returns null if not found
  }

  Future<void> connectWebSocket() async {
    try {
      String? driverId = await getUsername(); // Await the username retrieval
      driverId ??= "defaultDriver"; // Provide a fallback value if null
      print("driverId is $driverId");

      channel = IOWebSocketChannel.connect(
          "ws://34.46.215.218:8080/ws?driverId=$driverId");

      isConnected = true;
      print("✅ WebSocket connected successfully");

      channel?.stream.listen(
        (message) {
          print("📩 Received from server: $message");
          Map<String, dynamic> decodedMessage = jsonDecode(message);
          print(decodedMessage["message"]["message"]);
          setState(() {
            messageList.insert(
                0, decodedMessage["message"]); // Add message to the list
          });
        },
        onError: (error) {
          print("❌ WebSocket Error: $error");
          isConnected = false;
          reconnectWebSocket();
        },
        onDone: () {
          print("🔌 WebSocket closed. Attempting to reconnect...");
          isConnected = false;
          reconnectWebSocket();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("❌ WebSocket connection failed: $e");
      isConnected = false;
      reconnectWebSocket();
    }
  }

  void reconnectWebSocket() async {
    await Future.delayed(Duration(seconds: 5));
    print("🔄 Reconnecting WebSocket...");
    await connectWebSocket();
  }

  void sendLocationData(l.LocationData locationData) {
    if (isConnected) {
      channel?.sink.add(jsonEncode({
        "latitude": locationData.latitude ?? 0.0,
        "longitude": locationData.longitude ?? 0.0,
        "speed": locationData.speed ?? 0.0,
        "timestamp": DateTime.now().toIso8601String(),
      }));
    }
  }

  // Start sending data every 10 seconds
  void startSendingData(l.LocationData locationData) {
    var dataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isConnected) {
        channel?.sink.add(jsonEncode({
          "latitude": locationData.latitude ?? 0.0,
          "longitude": locationData.longitude ?? 0.0,
          "speed": locationData.speed ?? 0.0,
          "timestamp": DateTime.now().toIso8601String(),
        }));
      }
    });
  }
}

class LocationTile extends StatelessWidget {
  final String title;
  final Widget trailing;

  const LocationTile({super.key, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), trailing: trailing);
  }
}
