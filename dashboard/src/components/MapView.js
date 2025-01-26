import React, { useState, useEffect } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require("leaflet/dist/images/marker-icon-2x.png"),
  iconUrl: require("leaflet/dist/images/marker-icon.png"),
  shadowUrl: require("leaflet/dist/images/marker-shadow.png"),
});

const MapView = () => {
  const [locations, setLocations] = useState([]);

  useEffect(() => {
    const socket = new WebSocket("ws://<server-ip>:<port>/ws");
    socket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      setLocations((prev) => [...prev.filter(loc => loc.vehicleId !== data.vehicleId), data]);
    };

    return () => socket.close();
  }, []);

  return (
    <MapContainer center={[7.8731, 80.7718]} zoom={8} className="h-96">
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution="&copy; OpenStreetMap contributors"
      />
      {locations.map((loc) => (
        <Marker key={loc.vehicleId} position={[loc.latitude, loc.longitude]}>
          <Popup>
            <strong>Vehicle ID:</strong> {loc.vehicleId} <br />
            <strong>Speed:</strong> {loc.speed} km/h
          </Popup>
        </Marker>
      ))}
    </MapContainer>
  );
};

export default MapView;
