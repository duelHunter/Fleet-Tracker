package com.FleetTracker.server.controller;

import com.FleetTracker.server.handler.WebSocketHandler;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class WebSocketController {

    private final WebSocketHandler webSocketHandler;

    @Autowired
    public WebSocketController(WebSocketHandler webSocketHandler) {
        this.webSocketHandler = webSocketHandler;
    }

    // Broadcast a message to all connected clients
    @PostMapping("/send")
    public ResponseEntity<String> sendMessage(@RequestParam String message) {
        Map<String, WebSocketSession> sessions = webSocketHandler.getDriverSessions();
        if (sessions.isEmpty()) {
            return ResponseEntity.badRequest().body("No active WebSocket connections.");
        }

        for (WebSocketSession session : sessions.values()) {
            if (session.isOpen()) {
                try {
                    session.sendMessage(new TextMessage(message));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return ResponseEntity.ok("Message sent to all clients!");
    }

    // Send a warning message to a specific driver
    @PostMapping("/sendWarning")
    public ResponseEntity<String> sendWarning(@RequestParam String driverId, @RequestParam String message) {
        boolean success = webSocketHandler.sendWarningToDriver(driverId, message);
        if (success) {
            return ResponseEntity.ok("Warning sent to driver " + driverId);
        } else {
            return ResponseEntity.badRequest().body("Failed to send warning to driver " + driverId);
        }
    }
}
