const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const ROOT = __dirname;
const DEV  = process.env.DEV === '1';

const MIME = {
  '.html': 'text/html',
  '.js':   'text/javascript',
  '.css':  'text/css',
  '.glsl': 'text/plain',
  '.json': 'application/json',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.svg':  'image/svg+xml',
};

// ── SSE reload ──────────────────────────────────────────────
const sseClients = new Set();
function notifyReload() {
  sseClients.forEach(res => res.write('data: reload\n\n'));
}

// ── Watch for changes in dev mode ──────────────────────────
if (DEV) {
  // watch shaders/ → rebuild bundle + reload
  fs.watch(path.join(ROOT, 'shaders'), (_, filename) => {
    if (!filename?.endsWith('.glsl')) return;
    console.log(`[dev] ${filename} changed — rebuilding...`);
    delete require.cache[require.resolve('./build.js')];
    try { require('./build.js'); } catch (e) { console.error('[dev] build error:', e.message); }
    notifyReload();
  });

  // watch dev/ → reload on manifest.json or any .glsl change
  fs.watch(path.join(ROOT, 'dev'), { recursive: true }, (_, filename) => {
    if (!filename) return;
    if (filename === 'manifest.json' || filename.endsWith('.glsl')) {
      console.log(`[dev] dev/${filename} changed — reloading...`);
      notifyReload();
    }
  });

  console.log('[dev] watching shaders/ and dev/');
}

// ── Resolve file path, serving index.html for directories ──
function resolve(urlPath) {
  const stripped = urlPath.split('?')[0];
  let   filePath = path.join(ROOT, stripped);

  // if it's a directory, try index.html inside
  try {
    if (fs.statSync(filePath).isDirectory()) {
      filePath = path.join(filePath, 'index.html');
    }
  } catch {}

  return filePath;
}

http.createServer((req, res) => {
  // SSE endpoint
  if (DEV && req.url === '/__reload') {
    res.writeHead(200, {
      'Content-Type':  'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection':    'keep-alive',
    });
    res.write(': connected\n\n');
    sseClients.add(res);
    req.on('close', () => sseClients.delete(res));
    return;
  }

  const url      = req.url === '/' ? '/index.html' : req.url;
  const filePath = resolve(url);
  const ext      = path.extname(filePath);

  // redirect bare directory paths to trailing-slash so relative URLs resolve correctly
  const stripped = url.split('?')[0];
  try {
    if (!stripped.endsWith('/') && fs.statSync(path.join(ROOT, stripped)).isDirectory()) {
      res.writeHead(301, { Location: stripped + '/' });
      res.end();
      return;
    }
  } catch {}

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
      return;
    }

    if (DEV && ext === '.html') {
      data = Buffer.from(data.toString().replace('</body>',
        `<script>new EventSource('/__reload').onmessage=()=>location.reload()</script>\n</body>`
      ));
    }

    res.writeHead(200, { 'Content-Type': MIME[ext] || 'text/plain' });
    res.end(data);
  });
}).listen(PORT, () => {
  console.log(`ready at http://localhost:${PORT}`);
  if (DEV) console.log(`  dev page -> http://localhost:${PORT}/dev`);
});
