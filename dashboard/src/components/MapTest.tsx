"use client";

import React, { useState, useEffect } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";

// Configure the default icon for Leaflet
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://unpkg.com/leaflet@1.9.3/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.3/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.3/dist/images/marker-shadow.png",
});

const MapTest = () => {
  // Initialize location with a default value..
  const [location, setLocation] = useState<[number, number]>([7.471292, 80.041397]);

  useEffect(() => {
    // Open a WebSocket connection to your backend server.//ws://34.46.215.218:8080/ws
    const socket = new WebSocket("ws://34.46.215.218:8080/ws?driverId=$driverId123");

    socket.onopen = () => {
      console.log("Connected to WebSocket server");
    };

    socket.onmessage = (event) => {
      console.log("Received raw message:", event.data);
      
      try {
        // Step 1: Parse the main WebSocket message
        const mainData = JSON.parse(event.data);
        
  
        if (mainData.message) {
          let locationData;
  
          // Step 2: Check if `message` is a string and parse it
          if (typeof mainData.message === "string") {
            locationData = JSON.parse(mainData.message); // ✅ Properly parse inner JSON string
          } else {
            locationData = mainData.message;
          }
  
          // Step 3: Validate and update location state
          if (locationData.latitude !== undefined && locationData.longitude !== undefined) {
            setLocation([locationData.latitude, locationData.longitude]);
          } else {
            console.error("Invalid location data format:", locationData);
          }
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
    };

    // Clean up the WebSocket connection on unmount.
    return () => {
      socket.close();
    };
  }, []);

  return (
    <div className="h-screen w-full bg-white">
      <MapContainer
        center={location}
        zoom={8}
        scrollWheelZoom={false}
        style={{ height: "100%", width: "100%" }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <Marker position={location}>
          <Popup>
            Current Location: <br />
            Latitude: {location[0].toFixed(4)}, Longitude: {location[1].toFixed(4)}
          </Popup>
        </Marker>
      </MapContainer>
    </div>
  );
};

export default MapTest;
