package com.FleetTracker.server.controller;

import com.FleetTracker.server.handler.WebSocketHandler;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api")
public class WebSocketController {

    private final WebSocketHandler webSocketHandler;

    @Autowired
    public WebSocketController(WebSocketHandler webSocketHandler) {
        this.webSocketHandler = webSocketHandler;
    }

    @PostMapping("/send")
    public ResponseEntity<String> sendMessage(@RequestParam String message) {
        List<WebSocketSession> sessions = webSocketHandler.getSessions();
        if (sessions.isEmpty()) {
            return ResponseEntity.badRequest().body("No active WebSocket connections.");
        }

        for (WebSocketSession session : sessions) {
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
}
