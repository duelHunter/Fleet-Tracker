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

const MapTest = () => {
  const [drivers, setDrivers] = useState<{ driverId: string; latitude: number; longitude: number }[]>([]);
  const socketRef = useRef<WebSocket | null>(null); // WebSocket reference

  useEffect(() => {
    // Open WebSocket connection only once
    if (!socketRef.current) {
      socketRef.current = new WebSocket("ws://34.46.215.218:8080/ws?driverId=$driverId123");

      socketRef.current.onopen = () => {
        console.log("Connected to WebSocket server");
      };

      socketRef.current.onmessage = (event) => {
        console.log("Received raw message:", event.data);
        try {
          const mainData = JSON.parse(event.data);

          if (mainData.message) {
            let locationData;
            if (typeof mainData.message === "string") {
              locationData = JSON.parse(mainData.message); 
            } else {
              locationData = mainData.message;
            }

            if (locationData.latitude !== undefined && locationData.longitude !== undefined) {
              setDrivers((prevDrivers) => {
                const updatedDrivers = [...prevDrivers];
                const existingDriver = updatedDrivers.find(d => d.driverId === mainData.driverId);

                if (existingDriver) {
                  // Update existing driver's location
                  existingDriver.latitude = locationData.latitude;
                  existingDriver.longitude = locationData.longitude;
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
            } else {
              console.error("Invalid location data format:", locationData);
            }
          }
        } catch (error) {
          console.error("Error parsing WebSocket message:", error);
        }
      };

      socketRef.current.onerror = (error) => {
        console.error("WebSocket error:", error);
      };

      socketRef.current.onclose = () => {
        console.log("WebSocket connection closed");
      };
    }

    return () => {
      socketRef.current?.close();
      socketRef.current = null;
    };
  }, []); // 🚀 Runs only ONCE when component mounts (WebSocket persists)

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
