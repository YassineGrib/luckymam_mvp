#!/usr/bin/env node
/**
 * Firebase Hosting needs index.html; TanStack Start (Cloudflare preset) only emits JS/CSS.
 * Generates a minimal SPA shell that loads the Vite client bundle.
 */
import { readdirSync, writeFileSync, copyFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const publicDir = join(__dirname, "../.output/public");
const assetsDir = join(publicDir, "assets");

const assets = readdirSync(assetsDir);
const js = assets.find((f) => f.startsWith("index-") && f.endsWith(".js"));
const css = assets.find((f) => f.startsWith("styles-") && f.endsWith(".css"));

if (!js) {
  console.error("generateHostingIndex: no index-*.js in .output/public/assets — run npm run build first");
  process.exit(1);
}

const html = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Luckymam Admin</title>
    <link rel="icon" href="/favicon.ico" type="image/x-icon" />
    ${css ? `<link rel="stylesheet" href="/assets/${css}" />` : ""}
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300;400;500;600;700&family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700;800&display=swap"
    />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/assets/${js}"></script>
  </body>
</html>
`;

const indexPath = join(publicDir, "index.html");
writeFileSync(indexPath, html);
copyFileSync(indexPath, join(publicDir, "404.html"));
console.log(`generateHostingIndex: wrote index.html + 404.html (js=${js}${css ? `, css=${css}` : ""})`);
