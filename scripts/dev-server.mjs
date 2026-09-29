import http from "node:http";
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const port = Number(process.env.PORT || 4173);
const host = process.env.HOST || "127.0.0.1";

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml"
};

const server = http.createServer(async (req, res) => {
  try {
    const rawPath = decodeURIComponent(new URL(req.url, `http://${req.headers.host || host}`).pathname);
    const requested = rawPath === "/" ? "/index.html" : rawPath;
    const fullPath = path.resolve(root, "." + requested);
    if (!fullPath.startsWith(root + path.sep) && fullPath !== root) {
      res.writeHead(403).end("Forbidden");
      return;
    }
    const data = await fs.readFile(fullPath);
    res.writeHead(200, {
      "Content-Type": mime[path.extname(fullPath)] || "application/octet-stream",
      "Cache-Control": "no-store",
      "Cross-Origin-Opener-Policy": "same-origin"
    });
    res.end(data);
  } catch (error) {
    const code = error?.code === "ENOENT" ? 404 : 500;
    res.writeHead(code, { "Content-Type": "text/plain; charset=utf-8" });
    res.end(code === 404 ? "Not Found" : "Server Error");
  }
});

server.listen(port, host, () => {
  console.log(`Skin Aim Trainer Phase 1: http://${host}:${port}`);
});
