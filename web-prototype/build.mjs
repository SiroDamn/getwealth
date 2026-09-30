// Assembles the single-file page: <title>, <style>, mount point, engine + app scripts.
// dist/artifact.html is the fragment for publishing; dist/standalone.html adds a document skeleton for local viewing.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = dirname(fileURLToPath(import.meta.url));
const read = (f) => readFileSync(join(root, 'src', f), 'utf8');
const dark = read('dark-tokens.css').trim();
const css = read('style.css').replaceAll('/*DARK_TOKENS*/', dark);
const engine = read('engine.js').replace(/\nif \(typeof module[^\n]*\n?$/, '\n');
const app = read('app.js');
if ((engine + app).includes('</script')) throw new Error('script text must not contain a closing script tag');
const fragment = `<title>Reihum Prototyp</title>
<style>
${css}
</style>
<div id="app"></div>
<script>
${engine}
${app}
</script>
`;
mkdirSync(join(root, 'dist'), { recursive: true });
writeFileSync(join(root, 'dist', 'artifact.html'), fragment);
writeFileSync(join(root, 'dist', 'standalone.html'),
  `<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"></head><body style="margin:0">\n${fragment}</body></html>\n`);
console.log('built', fragment.length, 'bytes');
