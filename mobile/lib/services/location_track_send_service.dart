import 'dart:convert';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationTrackingService {
  // Singleton pattern
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  late WebSocketChannel _channel;

  // Initialize the service
  static Future<void> initialize() async {
    // Configure WebSocket connection (update URL accordingly)
    _instance._channel =
        WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080/ws'));

    // Listen for incoming WebSocket messages (optional)
    _instance._channel.stream.listen((message) {
      print('[WebSocket] Received: $message');
    }, onError: (error) {
      print('[WebSocket] Error: $error');
    });

    // Configure Background Geolocation
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      double speed = location.coords.speed; // m/s
      double speedKmh = speed * 3.6; // convert to km/h
      print(
          '[BackgroundGeolocation] Location update: ${location.coords.latitude}, '
          '${location.coords.longitude}, Speed: $speedKmh km/h');

      // Send location and speed via WebSocket
      String message = jsonEncode({
        'latitude': location.coords.latitude,
        'longitude': location.coords.longitude,
        'speed': speedKmh,
      });
      _instance._channel.sink.add(message);
      print('[WebSocket] Sent: $message');
    });

    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0, // Minimum distance between updates in meters
      stopOnTerminate: false, // Continue tracking when app is terminated
      startOnBoot: true, // Start tracking when device boots
      enableHeadless: true, // Allow background execution without UI
      debug: true, // Enables debug notifications for testing
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
  }

  // Optional: Provide a method to manually send a location message if needed
  void sendManualLocation(double lat, double lng, double speedKmh) {
    String message = jsonEncode({
      'latitude': lat,
      'longitude': lng,
      'speed': speedKmh,
    });
    _channel.sink.add(message);
    print('[WebSocket] Manually sent: $message');
  }

  // Clean up resources (e.g., when the app is completely closing)
  void dispose() {
    _channel.sink.close();
    bg.BackgroundGeolocation.stop();
  }
}
