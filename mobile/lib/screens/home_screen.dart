import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:location/location.dart' as l;
import '../widgets/location_tile.dart';
import '../utils/permissions.dart';
import '../services/websocket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

  late WebSocketService webSocketService;

  @override
  void initState() {
    super.initState();
    checkStatus();
    webSocketService = WebSocketService('ws://your-backend-url/ws/driver-location');
  }

  @override
  void dispose() {
    stopTracking();
    webSocketService.closeConnection();
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
    );
  }

  void requestEnableGps() async {
    gpsEnabled = await Permissions.isGpsEnabled();
    if (!gpsEnabled) {
      bool isGpsActive = await location.requestService();
      setState(() => gpsEnabled = isGpsActive);
    }
  }

  void requestLocationPermission() async {
    permissionGranted = await Permissions.requestLocationPermission();
    setState(() {});
  }

  void checkStatus() async {
    gpsEnabled = await Permissions.isGpsEnabled();
    permissionGranted = await Permissions.isPermissionGranted();
    setState(() {});
  }

  void startTracking() async {
    subscription = location.onLocationChanged.listen((event) {
      setState(() {
        // Convert speed from m/s to km/h
        currentSpeed = event.speed != null ? event.speed! * 3.6 : null;
        locations.insert(0, event);

        // Send data to backend
        if (event.latitude != null && event.longitude != null) {
          webSocketService.sendLocationData(
            event.latitude!,
            event.longitude!,
            currentSpeed ?? 0.0,
          );
        }
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
}
