import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { TanStackRouterVite } from "@tanstack/router-plugin/vite";
import tailwindcss from "@tailwindcss/vite";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig(() => {
  const base = process.env.VITE_BASE_URL || "/admin/";

  return {
    base,
    plugins: [
      TanStackRouterVite({
        target: "react",
        autoCodeSplitting: true,
      }),
      react(),
      tailwindcss(),
      tsconfigPaths({ projects: ["./tsconfig.json"] }),
    ],
    build: {
      outDir: "dist",
      emptyOutDir: true,
    },
  };
});
