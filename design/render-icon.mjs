// Renders design/app-icon.svg to a 1024x1024 RGB PNG WITHOUT alpha channel (App Store icons must be opaque).
// Usage: PLAYWRIGHT_MODULE=/path/to/playwright node design/render-icon.mjs <out.png>
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync } from 'node:fs';
import { deflateSync } from 'node:zlib';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const here = dirname(fileURLToPath(import.meta.url));
const out = process.argv[2] || join(here, 'app-icon-1024.png');
const svg = readFileSync(join(here, 'app-icon.svg'), 'utf8');

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1024, height: 1024 }, deviceScaleFactor: 1 });
await page.setContent(`<body style="margin:0;background:#000">${svg}</body>`);
const rgba = await page.evaluate(async () => {
  const svgEl = document.querySelector('svg');
  const blob = new Blob([new XMLSerializer().serializeToString(svgEl)], { type: 'image/svg+xml' });
  const img = new Image();
  img.src = URL.createObjectURL(blob);
  await img.decode();
  const c = document.createElement('canvas'); c.width = 1024; c.height = 1024;
  const g = c.getContext('2d'); g.fillStyle = '#000'; g.fillRect(0, 0, 1024, 1024); g.drawImage(img, 0, 0, 1024, 1024);
  return Array.from(g.getImageData(0, 0, 1024, 1024).data);
});
await browser.close();

// minimal PNG writer: 8-bit RGB (colour type 2), no alpha, filter type 0
const W = 1024, H = 1024;
const raw = Buffer.alloc((W * 3 + 1) * H);
for (let y = 0; y < H; y++) {
  raw[y * (W * 3 + 1)] = 0;
  for (let x = 0; x < W; x++) {
    const s = (y * W + x) * 4, d = y * (W * 3 + 1) + 1 + x * 3;
    raw[d] = rgba[s]; raw[d + 1] = rgba[s + 1]; raw[d + 2] = rgba[s + 2];
  }
}
const crcTable = Array.from({ length: 256 }, (_, n) => { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; return c >>> 0; });
const crc32 = (buf) => { let c = 0xffffffff; for (const b of buf) c = crcTable[(c ^ b) & 0xff] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; };
const chunk = (type, data) => {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type), data]);
  const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(body));
  return Buffer.concat([len, body, crc]);
};
const ihdr = Buffer.alloc(13); ihdr.writeUInt32BE(W, 0); ihdr.writeUInt32BE(H, 4); ihdr[8] = 8; ihdr[9] = 2; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
writeFileSync(out, Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk('IHDR', ihdr), chunk('IDAT', deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))]));
console.log('wrote', out);
