import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import StimulusHMR from "vite-plugin-stimulus-hmr";

export default defineConfig({
    plugins: [RubyPlugin(), StimulusHMR()],
    server: {
        hmr: true,
        overlay: true,
    },
    build: {
        manifest: true,
        outDir: "public/vite",
        rollupOptions: {
            output: {
                manualChunks: {},
            },
        },
    },
    base: "/vite/",
});
