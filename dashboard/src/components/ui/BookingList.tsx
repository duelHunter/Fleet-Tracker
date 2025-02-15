"use client";

import React, { useEffect, useState } from "react";
import Image from "next/image";
import { MdFlightTakeoff, MdFlightLand } from "react-icons/md";
const API_URL = process.env.NEXT_PUBLIC_API_URL;

interface BookingProps {
  tourName: string;
  duration: string;
  startDate: string;
  endDate: string;
  price: number;
  customerName: string;
  thumbnailUrl: string;
}

const BookingList: React.FC = () => {
  const [bookings, setBookings] = useState<BookingProps[]>([]);

  useEffect(() => {
    // Fetch bookings from the backend API
    const fetchBookings = async () => {
      try {
        const response = await fetch(`${API_URL}/admin/bookings`); 
        if (!response.ok) {
          throw new Error("Failed to fetch bookings");
        }
        const data = await response.json();
        setBookings(data);
      } catch (error) {
        console.error(error);
      }
    };

    fetchBookings();
  }, []);

  return (
    <div className="bg-white p-4 border rounded-2xl space-y-4">
      {bookings.length > 0 ? (
        bookings.map((booking, index) => (
          <div
            key={index}
            className="flex items-center justify-between border-b pb-4 last:border-b-0"
          >
            {/* Tour Image and Name */}
            <div className="flex items-center gap-3">
              <div className="relative w-12 h-12 rounded-lg overflow-hidden">
                <Image
                  src={booking.thumbnailUrl}
                  alt={booking.tourName}
                  fill
                  className="object-cover"
                />
              </div>
              <div>
                <h2 className="font-semibold">{booking.tourName}</h2>
                <p className="text-sm text-gray-500">{booking.duration}</p>
              </div>
            </div>

            {/* Dates */}
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <MdFlightTakeoff className="text-gray-500" />
                <span className="text-sm">{booking.startDate}</span>
              </div>
              <div className="flex items-center gap-2">
                <MdFlightLand className="text-gray-500" />
                <span className="text-sm">{booking.endDate}</span>
              </div>
            </div>

            {/* Price */}
            <div className="font-medium">{booking.price}$</div>

            {/* Customer Name */}
            <div className="text-blue-600 hover:underline cursor-pointer">
              {booking.customerName}
            </div>
          </div>
        ))
      ) : (
        <p className="text-center text-gray-500">No bookings available.</p>
      )}
    </div>
  );
};

export default BookingList;