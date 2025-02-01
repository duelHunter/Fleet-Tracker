// import 'package:flutter/material.dart';
// import 'package:mobile/services/websocket_service.dart';

// class WebSocketScreen extends StatefulWidget {
//   const WebSocketScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _WebSocketScreenState createState() => _WebSocketScreenState();
// }

// class _WebSocketScreenState extends State<WebSocketScreen> {
//   late WebSocketService _webSocketService;
//   final TextEditingController _messageController = TextEditingController();
//   List<String> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     _webSocketService = WebSocketService(
//         url: "ws://10.0.2.2:8080/ws"); // Localhost for Android Emulator

//     _webSocketService.stream.listen((message) {
//       setState(() {
//         messages.add(message);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _webSocketService.closeConnection();
//     super.dispose();
//   }

//   void sendMessage() {
//     if (_messageController.text.isNotEmpty) {
//       _webSocketService.sendMessage(_messageController.text);
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("WebSocket Test")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) => ListTile(
//                 title: Text(messages[index]),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration:
//                         const InputDecoration(labelText: "Enter message"),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

void main() {
  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    double speed = location.coords.speed ?? 0.0; // Speed in m/s
    double speedKmh = speed * 3.6; // Convert to km/h

    print('[Speed] $speedKmh km/h');
    sendToServer(location.coords.latitude, location.coords.longitude, speedKmh);
  });

  bg.BackgroundGeolocation.ready(bg.Config(
    desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
    distanceFilter: 10.0,
    stopOnTerminate: false,
    startOnBoot: true,
    enableHeadless: true,
    debug: true, // Enables debug notifications for testing
  )).then((bg.State state) {
    if (!state.enabled) {
      bg.BackgroundGeolocation.start();
    }
  });
}

void sendToServer(double lat, double lng, double speed) {
  // Send location + speed to your WebSocket or API server
}
