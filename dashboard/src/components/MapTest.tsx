import React, { useState, useEffect, useRef } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";

// Configure Leaflet Marker Icon
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://unpkg.com/leaflet@1.9.3/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.3/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.3/dist/images/marker-shadow.png",
});

interface Driver {
  driverId: string;
  latitude: number;
  longitude: number;
}

const MapTest = () => {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const driverTimeouts = useRef<Map<string, NodeJS.Timeout>>(new Map());
  const socketRef = useRef<WebSocket | null>(null);
  const reconnectAttempts = useRef<number>(0);  // Track reconnect attempts

  useEffect(() => {
    const connectWebSocket = () => {
      const socket = new WebSocket("ws://34.66.190.241:8080/ws?driverId=admin");
      socketRef.current = socket;

      socket.onopen = () => {
        console.log("Connected to WebSocket server");
        reconnectAttempts.current = 0;  // Reset retry counter on successful connection
      };

      socket.onmessage = (event) => {
        console.log("Received raw message:", event.data);

        try {
          const mainData = JSON.parse(event.data);
          if (!mainData.driverId) return;

          let locationData = typeof mainData.message === "string" ? JSON.parse(mainData.message) : mainData.message;

          if (locationData.latitude !== undefined && locationData.longitude !== undefined) {
            setDrivers((prevDrivers) => {
              const updatedDrivers = [...prevDrivers];
              const existingDriverIndex = updatedDrivers.findIndex(d => d.driverId === mainData.driverId);

              if (existingDriverIndex !== -1) {
                // Update existing driver location
                updatedDrivers[existingDriverIndex] = {
                  driverId: mainData.driverId,
                  latitude: locationData.latitude,
                  longitude: locationData.longitude,
                };
              } else {
                // Add new driver
                updatedDrivers.push({
                  driverId: mainData.driverId,
                  latitude: locationData.latitude,
                  longitude: locationData.longitude,
                });
              }

              return updatedDrivers;
            });

            // Reset the timeout for this driver
            if (driverTimeouts.current.has(mainData.driverId)) {
              clearTimeout(driverTimeouts.current.get(mainData.driverId)!);
            }

            // Remove the driver if no updates come in 30 seconds
            driverTimeouts.current.set(
              mainData.driverId,
              setTimeout(() => {
                setDrivers((prevDrivers) => prevDrivers.filter(d => d.driverId !== mainData.driverId));
                driverTimeouts.current.delete(mainData.driverId);
              }, 8000)
            );
          }
        } catch (error) {
          console.error("Error parsing WebSocket message:", error);
        }
      };

      socket.onerror = (error) => {
        console.error("WebSocket error:", error);
      };

      socket.onclose = () => {
        console.log("WebSocket connection closed");
        // Attempt to reconnect after 3 seconds
        if (reconnectAttempts.current < 5) { // Limit to 5 retries
          reconnectAttempts.current += 1;
          console.log(`Reconnecting... Attempt ${reconnectAttempts.current}`);
          setTimeout(connectWebSocket, 3000);
        } else {
          console.log("Maximum reconnect attempts reached.");
        }
      };
    };

    connectWebSocket(); // Initial WebSocket connection

    return () => {
      socketRef.current?.close();
      socketRef.current = null;
      driverTimeouts.current.forEach((timeout) => clearTimeout(timeout));
      driverTimeouts.current.clear();
    };
  }, []);

  return (
    <div className="h-screen w-full bg-white">
      <MapContainer center={[7.471292, 80.041397]} zoom={8} scrollWheelZoom={false} style={{ height: "100%", width: "100%" }}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {drivers.map((driver) => (
          <Marker key={driver.driverId} position={[driver.latitude, driver.longitude]}>
            <Popup>
              Driver ID: {driver.driverId} <br />
              Latitude: {driver.latitude.toFixed(4)}, Longitude: {driver.longitude.toFixed(4)}
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
};

export default MapTest;
