import MapTest from "../components/MapTest";
import ClientWrapper from "@/components/ClientWrapper";

// import dynamic from "next/dynamic";
// const MapTest = dynamic(() => import("../components/MapTest"), {
//   ssr: false, // Disable server-side rendering for this component
// });

export default function Home() {
  return (
    <div>
      <h1>Dashboard</h1>
      <ClientWrapper>
        <MapTest />
      </ClientWrapper>
      
    </div>
  );
}
