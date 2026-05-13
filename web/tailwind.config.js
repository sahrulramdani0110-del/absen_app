/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["var(--font-outfit)", "sans-serif"],
        mono: ["var(--font-jetbrains)", "monospace"],
      },
      colors: {
        ink: {
          DEFAULT: "#0f0e17",
          soft: "#2e2d3d",
          muted: "#6b6a7e",
        },
        paper: {
          DEFAULT: "#f5f4f0",
          warm: "#fffdf7",
        },
        accent: {
          DEFAULT: "#4f46e5",
          light: "#818cf8",
          soft: "#eef2ff",
        },
        success: "#10b981",
        warning: "#f59e0b",
        danger: "#ef4444",
      },
      borderRadius: {
        xl: "1rem",
        "2xl": "1.5rem",
      },
    },
  },
  plugins: [],
};
