import { defineConfig } from "vite";
export default defineConfig({
  build: { outDir: "../Rental.Api/wwwroot", emptyOutDir: true },
  server: { proxy: { "/api": "http://localhost:5247" } },
});
