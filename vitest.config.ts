import { fileURLToPath, URL } from 'node:url'

import react from '@vitejs/plugin-react'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./app/frontend', import.meta.url)),
    },
  },
  test: {
    environment: 'jsdom',
    setupFiles: ['./app/frontend/test/setup.ts'],
    include: ['app/frontend/**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      // Everything testable is in scope, tested or not. Entrypoints and
      // type declarations are bootstrap/compile-time code with no unit
      // surface; the system suite exercises them in a real browser
      // (docs/testing.md).
      include: [
        'app/frontend/pages/**',
        'app/frontend/components/**',
        'app/frontend/lib/**',
      ],
      exclude: ['**/*.test.{ts,tsx}'],
      thresholds: {
        lines: 100,
        branches: 100,
        functions: 100,
        statements: 100,
      },
      reporter: ['text', 'html'],
    },
  },
})
