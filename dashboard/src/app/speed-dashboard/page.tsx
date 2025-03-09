"use client";

import React, { useEffect, useState } from "react";
import { MdSpeed, MdWarning } from "react-icons/md";
import { SidebarDemo } from "@/components/SidebarDemo";

interface DriverData {
  driverId: string;
  speed: number;
}

const Page: React.FC = () => {
  const [drivers, setDrivers] = useState<DriverData[]>([]);
  const socketRef = React.useRef<WebSocket | null>(null);
  const reconnectTimeout = React.useRef<NodeJS.Timeout | null>(null);
  const MAX_RECONNECT_ATTEMPTS = 5;
  let reconnectAttempts = 0;

  const connectWebSocket = () => {
    if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN) return;

    console.log("Connecting to WebSocket...");
    socketRef.current = new WebSocket("ws://34.46.215.218:8080/ws?driverId=admin");

    socketRef.current.onopen = () => {
      console.log("Connected to WebSocket server");
      reconnectAttempts = 0; // Reset reconnect attempts on successful connection
    };

    socketRef.current.onmessage = (event) => {
      try {
        const mainData = JSON.parse(event.data);
        if (!mainData.driverId || !mainData.message) return;

        let messageData = typeof mainData.message === "string" ? JSON.parse(mainData.message) : mainData.message;

        if (typeof messageData.speed === "number") {
          setDrivers((prevDrivers) => {
            const updatedDrivers = new Map(prevDrivers.map((d) => [d.driverId, d]));
            updatedDrivers.set(mainData.driverId, { driverId: mainData.driverId, speed: messageData.speed });

            return Array.from(updatedDrivers.values()).sort((a, b) => b.speed - a.speed);
          });
        }
      } catch (error) {
        console.error("Error parsing WebSocket message:", error);
      }
    };

    socketRef.current.onerror = (error) => {
      console.error("WebSocket error:", error);
    };

    socketRef.current.onclose = (event) => {
      console.warn("WebSocket closed", event.reason);
      socketRef.current = null;

      // Attempt to reconnect if it wasn't a manual closure
      if (event.code !== 1000 && reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
        const delay = Math.min(5000, 1000 * 2 ** reconnectAttempts); // Exponential backoff (max 5s)
        console.log(`Reconnecting in ${delay / 1000}s...`);
        reconnectTimeout.current = setTimeout(connectWebSocket, delay);
        reconnectAttempts++;
      }
    };
  };

  useEffect(() => {
    connectWebSocket();

    return () => {
      if (socketRef.current) {
        socketRef.current.close(1000, "Component unmounted");
      }
      if (reconnectTimeout.current) {
        clearTimeout(reconnectTimeout.current);
      }
    };
  }, []);

  const sendWarning = (driverId: string) => {
    if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN) {
      const warningMessage = JSON.stringify({ type: "warning", message: "Reduce speed immediately!", driverId });
      socketRef.current.send(warningMessage);
      console.log(`Warning sent to ${driverId}`);
    } else {
      console.warn("WebSocket is not open. Cannot send warning.");
    }
  };

  return (
    <SidebarDemo>
      <div className="bg-gray-50 border rounded-2xl p-6 shadow-md w-full">
        <h1 className="text-2xl font-bold mb-4 text-gray-800">Speed Dashboard</h1>
        {drivers.map((driver, index) => (
          <div key={index} className="flex items-center justify-between p-4 border-b last:border-none">
            {/* Driver Info */}
            <div className="flex items-center">
              <div className="ml-4">
                <h3 className="text-lg font-semibold text-gray-800">{driver.driverId}</h3>
                <p className="text-sm text-gray-600 flex items-center gap-1">
                  <MdSpeed className="text-blue-500" /> {driver.speed.toFixed(2)} km/h
                </p>
              </div>
            </div>

            {/* Warning Button */}
            <button
              className="flex items-center gap-2 bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition"
              onClick={() => sendWarning(driver.driverId)}
            >
              <MdWarning /> Warning
            </button>
          </div>
        ))}
      </div>
    </SidebarDemo>
  );
};

export default Page;
