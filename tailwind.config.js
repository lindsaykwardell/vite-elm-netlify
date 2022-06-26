/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx,elm}"],
  theme: {
    extend: {
      fontFamily: {
        anek: ["'Anek Latin'", "sans-serif"],
        bitter: ["Bitter", "serif"],
      },
    },
  },
  plugins: [],
};
