"use client";

import React, { useState, useEffect } from "react";
import { Sidebar, SidebarBody, SidebarLink } from "@/components/ui/sidebar";
import HeavenlyLogo from "../../public/LOGO.png";
import {
  IconArrowLeft,
  IconBrandTabler,
  IconSettings,
  IconUserBolt,
  IconLogout,
  IconClipboardText,
  IconCreditCardPay,
  IconBookmarks,
  IconListDetails,
} from "@tabler/icons-react";
import Link from "next/link";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

export function SidebarDemo({ children }: Readonly<{ children: React.ReactNode }>) {
  const links = [
    {
      label: "Map",
      href: "/",
      icon: (
        <IconBrandTabler className="text-neutral-700 dark:text-neutral-200 h-5 w-5 flex-shrink-0" />
      ),
    },
    {
      label: "Speed Monitor",
      href: "/speed-dashboard",
      icon: (
        <IconUserBolt className="text-neutral-700 dark:text-neutral-200 h-5 w-5 flex-shrink-0" />
      ),
    },
    {
      label: "Your Trips",
      href: "/yourtrips",
      icon: (
        <IconArrowLeft className="text-neutral-700 dark:text-neutral-200 h-5 w-5 flex-shrink-0" />
      ),
    },
    {
      label: "Settings",
      href: "/settings",
      icon: (
        <IconSettings className="text-neutral-700 dark:text-neutral-200 h-5 w-5 flex-shrink-0" />
      ),
    },
  ];

  const [open, setOpen] = useState(false);
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const token = localStorage.getItem("token");
      setIsLoggedIn(!!token);
    }
  }, []);

  const handleLogoutClick = () => {
    setShowLogoutModal(true);
  };

  const confirmLogout = () => {
    localStorage.removeItem("token");
    setIsLoggedIn(false);
    setShowLogoutModal(false);
    window.location.href = "/";
  };

  return (
    <div
      className={cn(
        "rounded-md flex flex-col md:flex-row bg-white dark:bg-neutral-800 w-full flex-1 max-w-full mx-auto border border-neutral-200 dark:border-neutral-700 overflow-hidden",
        "h-auto"
      )}
    >
      <Sidebar open={open} setOpen={setOpen}>
        <SidebarBody className="justify-between gap-10 h-screen pb-16">
          <div className="flex flex-col flex-1 overflow-y-auto overflow-x-hidden pt-2 ">
            <Link href="/" legacyBehavior>
              <a className="flex items-center space-x-3 rtl:space-x-reverse">
                <img src={HeavenlyLogo.src} className="h-24" alt="Heavenly Logo"/>
              </a>
            </Link>
            <div className="mt-8 flex flex-col gap-2">
              {links.map((link, idx) => (
                <SidebarLink key={idx} link={link} />
              ))}
              <button
                onClick={handleLogoutClick}
                className="flex items-center gap-2 py-2 text-left text-neutral-700 dark:text-neutral-200 hover:bg-neutral-100 dark:hover:bg-neutral-900 rounded-lg transition-all"
              >
                <IconLogout className="h-5 w-5 flex-shrink-0" />
                <span>Logout</span>
              </button>
            </div>
          </div>
        </SidebarBody>
      </Sidebar>

      {children}

      {showLogoutModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center">
          <div className="bg-white p-6 rounded-lg shadow-lg">
            <h2 className="text-lg font-bold mb-4">Are you sure you want to logout?</h2>
            <div className="flex space-x-4">
              <button
                onClick={confirmLogout}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 focus:outline-none"
              >
                Yes, Logout
              </button>
              <button
                onClick={() => setShowLogoutModal(false)}
                className="px-4 py-2 bg-gray-400 text-white rounded-lg hover:bg-gray-500 focus:outline-none"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export const Logo = () => {
  return (
    <Link
      href="/"
      className="font-normal flex space-x-2 items-center text-sm text-black py-1 relative z-20"
    >
      <motion.span
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="font-medium text-black dark:text-white whitespace-pre"
      >
        <img src="Logo.svg" className="h-8" alt="Heavenly Logo" />
      </motion.span>
    </Link>
  );
};
