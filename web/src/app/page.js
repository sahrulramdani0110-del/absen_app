"use client";
import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    const token = document.cookie.includes("token");
    router.replace(token ? "/dashboard" : "/auth/login");
  }, [router]);

  return null;
}
