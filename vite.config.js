import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'icons/*.png', 'screenshots/*.png'],
      manifest: {
        name: 'RevisionOS',
        short_name: 'RevisionOS',
        description: 'Premium spaced repetition & revision planner for serious students',
        theme_color: '#0A0A0F',
        background_color: '#0A0A0F',
        display: 'standalone',
        orientation: 'portrait-primary',
        scope: '/',
        start_url: '/',
        icons: [
          { src: '/icons/icon-72x72.png', sizes: '72x72', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-96x96.png', sizes: '96x96', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-128x128.png', sizes: '128x128', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-144x144.png', sizes: '144x144', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-152x152.png', sizes: '152x152', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-192x192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-384x384.png', sizes: '384x384', type: 'image/png', purpose: 'maskable any' },
          { src: '/icons/icon-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable any' }
        ],
        screenshots: [
          { src: '/screenshots/desktop.png', sizes: '1280x720', type: 'image/png', form_factor: 'wide' },
          { src: '/screenshots/mobile.png', sizes: '390x844', type: 'image/png', form_factor: 'narrow' }
        ],
        categories: ['education', 'productivity'],
        shortcuts: [
          {
            name: 'Today\'s Revisions',
            short_name: 'Today',
            description: 'View today\'s revision tasks',
            url: '/dashboard',
            icons: [{ src: '/icons/icon-96x96.png', sizes: '96x96' }]
          },
          {
            name: 'Add Chapter',
            short_name: 'Add',
            description: 'Add a new chapter',
            url: '/chapters/new',
            icons: [{ src: '/icons/icon-96x96.png', sizes: '96x96' }]
          }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/.*\.supabase\.co\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'supabase-cache',
              expiration: { maxEntries: 100, maxAgeSeconds: 60 * 60 * 24 },
              cacheableResponse: { statuses: [0, 200] }
            }
          },
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: { maxEntries: 10, maxAgeSeconds: 60 * 60 * 24 * 365 },
              cacheableResponse: { statuses: [0, 200] }
            }
          }
        ]
      },
      devOptions: { enabled: true }
    })
  ],
  resolve: {
    alias: { '@': '/src' }
  }
})
