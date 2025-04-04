package com.FleetTracker.server.handler;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class WebSocketHandler extends TextWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketHandler.class);

    // Map to store sessions keyed by driverId
    private final Map<String, WebSocketSession> driverSessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        logger.info(String.valueOf("meeeeeeeeee seesion is "+session));
        // Retrieve driverId from the connection URL query parameter
        String driverId = getDriverIdFromSession(session);
        if (driverId != null) {
            driverSessions.put(driverId, session);
            logger.info("Driver " + driverId + " connected with session " + session.getId());
        } else {
            logger.warn("Connection established without a driverId. Session: " + session.getId());
            //close the websocket connection
            session.close(CloseStatus.BAD_DATA);
        }
    }

    // Helper method to extract driverId from the session URI
    private String getDriverIdFromSession(WebSocketSession session) {
        if (session.getUri() != null && session.getUri().getQuery() != null) {
            String query = session.getUri().getQuery();
            String[] params = query.split("&"); // Support multiple params
            for (String param : params) {
                String[] keyValue = param.split("=");
                if (keyValue.length == 2 && keyValue[0].equals("driverId")) {
                    return keyValue[1]; // Return the extracted driverId
                }
            }
        }
        return null;
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {
        logger.info("Received message: " + message.getPayload());
        String driverId = getDriverIdFromSession(session);

        if (driverId != null) {
            try {
                // Step 1: Create a valid JSON structure by wrapping the received message payload in proper JSON
                // Escape the inner message content to ensure it's safe to be inserted as JSON string
                String payload = message.getPayload();
                String newMessage = String.format("{\"driverId\": \"%s\", \"message\": %s}", driverId, payload);

                // Step 2: Broadcast the new message with driverId to all connected clients
                for (WebSocketSession s : driverSessions.values()) {
                    if (s.isOpen()) {
                        s.sendMessage(new TextMessage(newMessage));
                    }
                }

                logger.info("Message with driverId sent: " + newMessage);
            } catch (Exception e) {
                logger.error("Error handling message", e);
            }
        } else {
            logger.warn("DriverId not found for session: " + session.getId());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        // Remove the session by searching for the driverId
        String driverId = null;
        for (Map.Entry<String, WebSocketSession> entry : driverSessions.entrySet()) {
            if (entry.getValue().getId().equals(session.getId())) {
                driverId = entry.getKey();
                break;
            }
        }
        if (driverId != null) {
            driverSessions.remove(driverId);
            logger.info("Driver " + driverId + " disconnected, session " + session.getId());
        } else {
            logger.info("WebSocket connection closed: " + session.getId());
        }
    }

    // Method to broadcast a message to all connected clients
    public void broadcast(String message) {
        for (WebSocketSession session : driverSessions.values()) {
            if (session.isOpen()) {
                try {
                    session.sendMessage(new TextMessage(message));
                } catch (IOException e) {
                    logger.error("Error broadcasting message to session " + session.getId(), e);
                }
            }
        }
    }

    // Method to send a warning alert to a specific driver
    public boolean sendWarningToDriver(String driverId, String warningMessage) {
        WebSocketSession session = driverSessions.get(driverId);
        if (session != null && session.isOpen()) {
            try {
                // Construct a JSON formatted warning message
                String jsonMessage = "{\"type\": \"warning\", \"message\": \"" + warningMessage + "\"}";
                session.sendMessage(new TextMessage(jsonMessage));
                logger.info("Sent warning to driver " + driverId + ": " + jsonMessage);
                return true;
            } catch (IOException e) {
                logger.error("Error sending warning to driver " + driverId, e);
                return false;
            }
        }
        logger.warn("No active session for driver " + driverId);
        return false;
    }

    // Expose the current sessions map (if needed)
    public Map<String, WebSocketSession> getDriverSessions() {
        return driverSessions;
    }
}
