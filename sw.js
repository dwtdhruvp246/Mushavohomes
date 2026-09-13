const CACHE_PREFIX = 'mushavo-pwa-';
const BUILD_VERSION = '__MUSHAVO_BUILD_VERSION__';
const SHELL_CACHE = `${CACHE_PREFIX}shell-${BUILD_VERSION}`;
const OFFLINE_URL = '/offline';

const EMERGENCY_OFFLINE_HTML = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Offline | Mushavo Homes</title>
</head>
<body>
  <main>
    <h1>You’re offline</h1>
    <p>Mushavo Homes cannot connect right now. Reconnect to continue securely.</p>
    <button type="button" onclick="window.location.reload()">Try again</button>
  </main>
</body>
</html>`;

const PRECACHE_ASSETS = [
  OFFLINE_URL,
  '/manifest.webmanifest',
  '/mushavo-logo.png',
  '/icons/pwa-192.png',
  '/icons/pwa-512.png',
  '/icons/pwa-maskable-192.png',
  '/icons/pwa-maskable-512.png',
  '/icons/apple-touch-icon.png'
];

const CACHE_FIRST_ASSETS = new Set([
  '/mushavo-logo.png',
  '/icons/pwa-192.png',
  '/icons/pwa-512.png',
  '/icons/pwa-maskable-192.png',
  '/icons/pwa-maskable-512.png',
  '/icons/apple-touch-icon.png'
]);

async function getOfflineResponse() {
  try {
    const offlineRequest = new Request(
      new URL(OFFLINE_URL, self.location.origin).href
    );
    const shellCache = await caches.open(SHELL_CACHE);
    const cachedResponse = await shellCache.match(offlineRequest, {
      ignoreSearch: true
    });

    if (cachedResponse) return cachedResponse;
  } catch (error) {
    // Continue to the privacy-safe response if browser cache storage is unavailable.
  }

  return new Response(EMERGENCY_OFFLINE_HTML, {
    status: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-store'
    }
  });
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(SHELL_CACHE)
      .then((cache) => cache.addAll(PRECACHE_ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith(CACHE_PREFIX) && key !== SHELL_CACHE)
          .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);

  // Supabase, CDNs and every other third-party request remain network-only.
  if (url.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(() => getOfflineResponse())
    );
    return;
  }

  if (url.pathname === '/manifest.webmanifest') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response.ok) {
            const responseCopy = response.clone();
            caches.open(SHELL_CACHE).then((cache) => cache.put(request, responseCopy));
          }
          return response;
        })
        .catch(() => caches.match(request))
    );
    return;
  }

  if (CACHE_FIRST_ASSETS.has(url.pathname)) {
    event.respondWith(
      caches.match(request).then((cachedResponse) => {
        if (cachedResponse) return cachedResponse;

        return fetch(request).then((response) => {
          if (response.ok) {
            const responseCopy = response.clone();
            caches.open(SHELL_CACHE).then((cache) => cache.put(request, responseCopy));
          }
          return response;
        });
      })
    );
  }
});
