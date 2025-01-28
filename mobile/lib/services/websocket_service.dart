import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));

  void sendLocation(double latitude, double longitude, double speed) {
    final data = jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
    });
    channel.sink.add(data);
  }

  Stream<dynamic> receiveAlerts() {
    return channel.stream.map((message) => jsonDecode(message));
  }
}
