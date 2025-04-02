"use client";

import React, { useEffect, useState, useRef } from "react";
import { MdSpeed, MdWarning } from "react-icons/md";
import { SidebarDemo } from "@/components/SidebarDemo";

interface DriverData {
  driverId: string;
  speed: number;
}

const Page: React.FC = () => {
  const [drivers, setDrivers] = useState<DriverData[]>([]);
  const socketRef = useRef<WebSocket | null>(null);
  const reconnectTimeout = useRef<NodeJS.Timeout | null>(null);
  const driverTimeouts = useRef<Map<string, NodeJS.Timeout>>(new Map());
  const reconnectAttempts = useRef(0);

  useEffect(() => {
    let isUnmounted = false;

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
          if (!mainData.driverId || !mainData.message) return;

          let messageData = typeof mainData.message === "string"
            ? JSON.parse(mainData.message)
            : mainData.message;

          if (typeof messageData.speed === "number") {
            setDrivers((prevDrivers) => {
              const updatedDrivers = new Map(prevDrivers.map((d) => [d.driverId, d]));
              updatedDrivers.set(mainData.driverId, {
                driverId: mainData.driverId,
                speed: messageData.speed,
              });
              return Array.from(updatedDrivers.values()).sort((a, b) => b.speed - a.speed);
            });

            const existingTimeout = driverTimeouts.current.get(mainData.driverId);
            if (existingTimeout) clearTimeout(existingTimeout);

            const timeout = setTimeout(() => {
              setDrivers((prev) =>
                prev.filter((d) => d.driverId !== mainData.driverId)
              );
              driverTimeouts.current.delete(mainData.driverId);
            }, 10000);

            driverTimeouts.current.set(mainData.driverId, timeout);
          }
        } catch (error) {
          console.error("Error parsing WebSocket message:", error);
        }
      };

      socket.onerror = (error) => {
        console.error("WebSocket error:", error);
      };

      socket.onclose = (event) => {
        console.warn("WebSocket closed:", event.reason);
        socketRef.current = null;

        if (!isUnmounted && event.code !== 1000 && reconnectAttempts.current < 5) {
          const delay = Math.min(5000, 1000 * 2 ** reconnectAttempts.current);
          console.log(`Reconnecting in ${delay / 1000}s...`);
          reconnectTimeout.current = setTimeout(connectWebSocket, delay);
          reconnectAttempts.current++;
        }
      };
    };

    connectWebSocket();

    return () => {
      isUnmounted = true;

      if (socketRef.current) {
        socketRef.current.close(1000, "Component unmounted");
        socketRef.current = null;
      }

      if (reconnectTimeout.current) {
        clearTimeout(reconnectTimeout.current);
      }

      driverTimeouts.current.forEach((timeout) => clearTimeout(timeout));
      driverTimeouts.current.clear();

      console.log("Cleaned up WebSocket, reconnects, and driver timeouts.");
    };
  }, []);

  const sendWarning = (driverId: string) => {
    if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN) {
      const warningMessage = JSON.stringify({
        type: "warning",
        message: "Reduce speed immediately!",
        driverId,
      });
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
        {drivers.map((driver) => (
          <div
            key={driver.driverId}
            className="flex items-center justify-between p-4 border-b last:border-none"
          >
            <div className="flex items-center">
              <div className="ml-4">
                <h3 className="text-lg font-semibold text-gray-800">
                  {driver.driverId}
                </h3>
                <p className="text-sm text-gray-600 flex items-center gap-1">
                  <MdSpeed className="text-blue-500" />{" "}
                  {driver.speed.toFixed(2)} km/h
                </p>
              </div>
            </div>
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
