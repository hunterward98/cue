import { fileURLToPath, URL } from 'node:url'

import inertia from '@inertiajs/vite'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import checker from 'vite-plugin-checker'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    tailwindcss(),
    RubyPlugin(),
    inertia(),
    react(),
    // Type errors fail `vite build` (and therefore assets:precompile and the
    // Docker image build), not just CI — foundation plan_2 requirement.
    checker({ typescript: { tsconfigPath: 'tsconfig.app.json' } }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app/frontend', import.meta.url)),
    },
  },
})
