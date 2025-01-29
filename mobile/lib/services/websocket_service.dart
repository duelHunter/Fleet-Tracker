// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class WebSocketService {
//   final WebSocketChannel channel =
//       WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));

//   void sendLocation(double latitude, double longitude, double speed) {
//     final data = jsonEncode({
//       'latitude': latitude,
//       'longitude': longitude,
//       'speed': speed,
//     });
//     channel.sink.add(data);
//   }

//   Stream<dynamic> receiveAlerts() {
//     return channel.stream.map((message) => jsonDecode(message));
//   }
// }


import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  late WebSocketChannel _channel;

  WebSocketService({required this.url}) {
    _channel = IOWebSocketChannel.connect(url);
  }

  Stream get stream => _channel.stream;

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void closeConnection() {
    _channel.sink.close();
  }
}
