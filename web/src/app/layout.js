import { Outfit, JetBrains_Mono } from "next/font/google";
import { Toaster } from "react-hot-toast";
import "./globals.css";

const outfit = Outfit({
  subsets: ["latin"],
  variable: "--font-outfit",
});

const jetbrains = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains",
});

export const metadata = {
  title: "AbsensiKu — Sistem Absensi Digital",
  description: "Sistem absensi digital untuk sekolah dan organisasi",
  manifest: "/manifest.json",
  themeColor: "#ff8906",
  viewport: "width=device-width, initial-scale=1, maximum-scale=1",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "AbsensiKu",
  },
};

export default function RootLayout({ children }) {
  return (
    <html lang="id" className={`${outfit.variable} ${jetbrains.variable}`}>
      <body className="bg-paper font-sans text-ink antialiased">
        <Toaster
          position="top-right"
          toastOptions={{
            style: {
              fontFamily: "var(--font-outfit)",
              borderRadius: "0.75rem",
              background: "#0f0e17",
              color: "#f5f4f0",
            },
          }}
        />
        {children}
      </body>
    </html>
  );
}
