/* Olamilekanwaliu CMS — service worker (offline app shell) */
const CACHE='ocms-v1';
const SHELL=[
  '/admin/app.js',
  '/admin/vendor/supabase.js',
  '/cms-config.js',
  '/admin/manifest.webmanifest',
  '/admin/icons/icon-192.png',
  '/admin/icons/icon-512.png',
  '/admin/icons/apple-180.png'
];
self.addEventListener('install', function(e){
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(SHELL).catch(function(){}); }));
});
self.addEventListener('activate', function(e){
  e.waitUntil(caches.keys().then(function(keys){
    return Promise.all(keys.filter(function(k){return k!==CACHE;}).map(function(k){return caches.delete(k);}));
  }).then(function(){ return self.clients.claim(); }));
});
self.addEventListener('fetch', function(e){
  var req=e.request;
  if(req.method!=='GET') return;                       // never cache writes
  var url=new URL(req.url);
  if(url.origin!==self.location.origin) return;        // never touch Supabase (cross-origin) — lets live data through
  if(req.mode==='navigate'){                            // pages: network-first, fall back to cache when offline
    e.respondWith(fetch(req).then(function(res){
      var copy=res.clone(); caches.open(CACHE).then(function(c){c.put(req,copy);}); return res;
    }).catch(function(){ return caches.match(req).then(function(m){return m||caches.match('/admin/dashboard');}); }));
    return;
  }
  // assets: cache-first, then network (and cache it)
  e.respondWith(caches.match(req).then(function(m){
    return m || fetch(req).then(function(res){
      var copy=res.clone(); caches.open(CACHE).then(function(c){c.put(req,copy);}); return res;
    }).catch(function(){ return m; });
  }));
});
