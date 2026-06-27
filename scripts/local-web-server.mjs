/**
 * Local static server for build/web — no proxy loop (http-server -P breaks on /app/*).
 * - / and marketing paths serve real HTML
 * - /app/* serves Flutter shell from 404.html (same as Cloudflare serve.json rewrite)
 */
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const port = parseInt(process.env.PORT || "8080", 10);
const host = process.env.HOST || "127.0.0.1";
const root = process.cwd();

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".woff2": "font/woff2",
  ".wasm": "application/wasm",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml",
};

function safeJoin(urlPath) {
  const decoded = decodeURIComponent(urlPath.split("?")[0]);
  const rel = decoded.replace(/^\/+/, "").replace(/\//g, path.sep);
  const full = path.resolve(root, rel);
  if (!full.startsWith(root + path.sep) && full !== root) return null;
  return full;
}

function resolveFile(urlPath) {
  if (urlPath === "/" || urlPath === "") {
    return path.join(root, "index.html");
  }
  if (urlPath.startsWith("/app/")) {
    return path.join(root, "404.html");
  }

  const filePath = safeJoin(urlPath);
  if (!filePath) return null;

  if (fs.existsSync(filePath)) {
    if (fs.statSync(filePath).isDirectory()) {
      const index = path.join(filePath, "index.html");
      return fs.existsSync(index) ? index : null;
    }
    return filePath;
  }

  const withHtml = `${filePath}.html`;
  if (fs.existsSync(withHtml)) return withHtml;

  const indexInDir = path.join(filePath, "index.html");
  if (fs.existsSync(indexInDir)) return indexInDir;

  return null;
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url || "/", `http://${host}`);
  const filePath = resolveFile(url.pathname);

  if (!filePath) {
    res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("Not found");
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("Server error");
      return;
    }
    const ext = path.extname(filePath).toLowerCase();
    res.writeHead(200, { "Content-Type": MIME[ext] || "application/octet-stream" });
    res.end(data);
  });
});

server.listen(port, host, () => {
  console.log(`Local web: http://${host}:${port}`);
  console.log(`Credits dashboard: http://${host}:${port}/app/profile`);
});
