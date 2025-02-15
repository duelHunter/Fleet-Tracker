"use client";

import { SidebarDemo } from "@/components/SidebarDemo";
import MapTest from "../components/MapTest";
import ClientWrapper from "@/components/ClientWrapper";

// import dynamic from "next/dynamic";
// const MapTest = dynamic(() => import("../components/MapTest"), {
//   ssr: false, // Disable server-side rendering for this component
// } );

export default function Home() {
  return (
    <div className="bg-white">
      <SidebarDemo>
        <ClientWrapper>
          <MapTest />
        </ClientWrapper>
      </SidebarDemo>
    </div>
  );
}
//done