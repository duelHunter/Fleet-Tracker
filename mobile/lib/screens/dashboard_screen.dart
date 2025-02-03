import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/alert_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool gpsEnabled = false;
  bool permissionGranted = false;
  l.Location location = l.Location();
  StreamSubscription? subscription;
  Timer? dataTimer;
  bool trackingEnabled = false;

  List<l.LocationData> locations = [];
  double? currentSpeed;

  IOWebSocketChannel? channel;
  bool isConnected = false;
  bool isReconnecting = false; // Prevent multiple reconnections

  @override
  void initState() {
    super.initState();
    checkStatus();
    connectWebSocket();
  }

  @override
  void dispose() {
    stopTracking();
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Location & Speed Tracker'),
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
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Lat: ${locations[index].latitude}, Lon: ${locations[index].longitude}",
                    ),
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
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var alwaysStatus = await Permission.locationAlways.request();
      setState(() => permissionGranted = alwaysStatus.isGranted);
    }
  }

  void checkStatus() async {
    gpsEnabled = await location.serviceEnabled();
    var status = await Permission.locationAlways.status;
    permissionGranted = status.isGranted;
    setState(() {});
  }

  void startTracking() {
    connectWebSocket();

    subscription = location.onLocationChanged.listen((event) {
      setState(() {
        currentSpeed = event.speed != null ? event.speed! * 3.6 : null;
        locations.insert(0, event);
      });

      sendLocationData(event);
    });

    // Start sending data every 10 seconds
    dataTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (locations.isNotEmpty) {
        sendLocationData(locations.first);
      }
    });

    setState(() => trackingEnabled = true);
  }

  void stopTracking() {
    subscription?.cancel();
    dataTimer?.cancel();

    setState(() {
      trackingEnabled = false;
      currentSpeed = null;
      locations.clear();
    });
  }

  Future<void> connectWebSocket() async {
    if (isConnected || isReconnecting) return; // Prevent multiple connections
    isReconnecting = true;

    try {
      channel = IOWebSocketChannel.connect("ws://34.46.215.218:8080/ws");
      isConnected = true;
      isReconnecting = false;
      print("✅ WebSocket connected successfully");

      channel?.stream.listen(
        (message) {
          print("📩 Received from server: $message");
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
    if (isConnected || isReconnecting) return;
    isReconnecting = true;

    await Future.delayed(const Duration(seconds: 5));
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
}

class LocationTile extends StatelessWidget {
  final String title;
  final Widget trailing;

  const LocationTile({Key? key, required this.title, required this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), trailing: trailing);
  }
}
