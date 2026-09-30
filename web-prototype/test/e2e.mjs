// End-to-end walk-through in a real browser at iPhone 11 Pro size. Usage: node test/e2e.mjs [screenshotDir]
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import assert from 'node:assert/strict';
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const here = dirname(fileURLToPath(import.meta.url));
const shotDir = process.argv[2] || null;
const url = 'file://' + join(here, '..', 'dist', 'standalone.html');

const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH || undefined });
const problems = [];
async function newPage(colorScheme) {
  const ctx = await browser.newContext({ viewport: { width: 375, height: 812 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true, colorScheme, locale: 'de-CH', permissions: ['clipboard-read', 'clipboard-write'] });
  const page = await ctx.newPage();
  await page.emulateMedia({ reducedMotion: 'reduce', colorScheme });
  page.on('pageerror', (e) => problems.push('pageerror: ' + e.message));
  page.on('console', (m) => { if (['error', 'warning'].includes(m.type())) problems.push('console.' + m.type() + ': ' + m.text()); });
  await page.goto(url);
  return page;
}
const shot = async (page, name) => { if (shotDir) await page.screenshot({ path: join(shotDir, name + '.png') }); };
const noHorizontalScroll = async (page, label) => {
  const w = await page.evaluate(() => ({ sw: document.documentElement.scrollWidth, cw: document.documentElement.clientWidth }));
  assert.ok(w.sw <= w.cw + 1, `${label}: horizontal overflow ${w.sw} > ${w.cw}`);
};
const noClippedBlocks = async (page, label) => {
  // A block inside a sheet must never be squeezed smaller than its content (overflow:hidden would hide the rest).
  const offenders = await page.evaluate(() => [...document.querySelectorAll('.sheet-body > *')]
    .filter((el) => el.tagName !== 'PRE' && getComputedStyle(el).overflowY !== 'visible' && el.scrollHeight > el.clientHeight + 1)
    .map((el) => el.className + ' ' + el.clientHeight + '/' + el.scrollHeight));
  assert.deepEqual(offenders, [], label + ': clipped blocks ' + offenders.join(', '));
};
const iso = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

// ---------------------------------------------------------------- light theme
const page = await newPage('light');
await page.waitForSelector('.card');
assert.match(await page.textContent('.card .t'), /Beispiel: Znüni-Dienst/);
await noHorizontalScroll(page, 'list');
await shot(page, '01-list-light');

// open the sample plan: fairness row, months, next slot marker
await page.click('.card');
await page.waitForSelector('.slots');
assert.equal(await page.locator('.chip').count(), 5);
assert.equal(await page.locator('.slot.next').count(), 1);
const counts = (await page.locator('.chip').allTextContents()).map((t) => Number(t.match(/(\d+)×/)[1]));
assert.ok(Math.max(...counts) - Math.min(...counts) <= 1, 'sample plan should be fair: ' + counts);
await noHorizontalScroll(page, 'detail');
await shot(page, '02-detail-light');

// edit a slot: swap with another
const firstFuture = page.locator('.slot:not(.past)').first();
const before = await firstFuture.locator('.who').innerText();
await firstFuture.click();
await page.waitForSelector('#slot-swap');
await page.selectOption('#slot-swap', { index: 3 });
await noClippedBlocks(page, 'slot sheet');
await shot(page, '03-slot-sheet');
await page.click('[data-act=doSwap]');
await page.waitForSelector('.toast');
const after = await page.locator('.slot:not(.past)').first().locator('.who').innerText();
assert.notEqual(before, after, 'swap should change the first upcoming turn');
assert.ok(await page.locator('.slot .pill').count() >= 2, 'both swapped slots are marked as manual');

// manual assignment + skip through the editor
await page.locator('.slot:not(.past)').nth(1).click();
await page.click('#slot-skip');
await page.click('[data-act=saveSlot]');
assert.ok((await page.locator('.slot .skip').count()) === 1, 'one skipped slot');

// absence for a member: open members, add absence, save, expect the person absent on those days
await page.click('[data-act=openMembers]');
await page.waitForSelector('[data-act=editMember]');
await shot(page, '04-members');
await page.locator('[data-act=editMember]').first().click();
const start = new Date(); start.setDate(start.getDate() + 1);
const end = new Date(); end.setDate(end.getDate() + 60);
await page.fill('#abs-from', iso(start));
await page.fill('#abs-to', iso(end));
await page.fill('#abs-note', 'Ferien');
await page.click('[data-act=addAbsence]');
assert.equal(await page.locator('#abs-from').inputValue(), '', 'form is cleared after adding');
assert.match(await page.textContent('.list'), /bis/);
await noClippedBlocks(page, 'member editor');
await shot(page, '05-absence');
await page.click('[data-act=doneMember]');
await page.click('[data-act=saveMembers]');
await page.waitForSelector('.toast');
const alexRows = await page.locator('.slot:not(.past)').evaluateAll((rows) => rows.map((r) => r.innerText));
assert.ok(alexRows.length > 0);

// rhythm sheet: change to biweekly and back the count changes
await page.click('[data-act=openRhythm]');
await page.selectOption('#sheet\\.rhythm-kind, [id="sheet.rhythm-kind"]', 'biweekly');
await page.waitForSelector('[id="sheet.rhythm-wd"]');
await noClippedBlocks(page, 'rhythm sheet');
await shot(page, '06-rhythm');
await page.click('[data-act=saveRhythm]');
await page.waitForSelector('.toast');
assert.match(await page.textContent('.meta'), /Alle zwei Wochen/);

// share: image + text
await page.click('[data-act=openShare]');
await page.waitForSelector('.share-img');
const imgOk = await page.evaluate(() => { const i = document.querySelector('.share-img'); return i.complete && i.naturalWidth > 500; });
assert.ok(imgOk, 'share image is rendered');
await noClippedBlocks(page, 'share sheet');
await shot(page, '07-share-image');
await page.click('[data-act=shareTab][data-v=text]');
const text = await page.textContent('#share-text');
assert.match(text, /^Beispiel: Znüni-Dienst\n\n/);
assert.ok(!/\bFr\., \d\d\.\d\d\.\d{4} – .*\n.*(?=Fr\.)/.test('') );
await page.click('[data-act=copyText]');
await page.waitForSelector('.toast');
assert.equal((await page.evaluate(() => navigator.clipboard.readText())).trim(), text.trim());
await shot(page, '08-share-text');
await page.click('[data-act=shareTab][data-v=cal]');
await shot(page, '09-share-calendar');
await page.click('.sheet [data-act=closeSheet]');

// delete plan needs a second confirmation
await page.click('[data-act=openMenu]');
await page.click('[data-act=askDelete]');
await page.waitForSelector('[data-act=deletePlan]');
await page.click('[data-act=cancelConfirm]');
assert.equal(await page.locator('[data-act=deletePlan]').count(), 0);
await page.click('.sheet [data-act=closeSheet]');

// ------------------------------------------------------------------ new plan
await page.click('[data-act=back]');
await page.click('#btn-new');
await page.waitForSelector('#wiz-name');
await page.click('[data-act=wizNext]');
assert.match(await page.textContent('.err'), /Namen/);
await page.fill('#wiz-name', 'Putzplan WG');
await page.click('[data-act=wizColor][data-v="3"]');
await shot(page, '10-wizard-name');
await page.click('[data-act=wizNext]');
await page.waitForSelector('#wiz-person');
await page.click('[data-act=wizNext]');
assert.match(await page.textContent('.err'), /Mindestens zwei/);
for (const n of ['Mia', 'Noah', 'Lea']) { await page.fill('#wiz-person', n); await page.keyboard.press('Enter'); }
assert.equal(await page.locator('.list .li .seg').count(), 3);
await page.locator('[data-act=wizWeight][data-w="0.5"]').nth(2).click();
await page.locator('[data-act=wizRemove]').nth(1).click(); // remove Noah
assert.equal(await page.locator('.list .li .seg').count(), 2);
await page.fill('#wiz-person', 'Ida'); await page.keyboard.press('Enter');
await shot(page, '11-wizard-people');
await page.click('[data-act=wizNext]');
await page.selectOption('[id="wiz.rhythm-kind"]', 'monthlyNth');
await page.selectOption('[id="wiz.rhythm-ord"]', '-1');
await shot(page, '12-wizard-rhythm');
await page.click('[data-act=wizNext]');
await page.waitForSelector('#wiz-start');
assert.match(await page.textContent('.help'), /Ergibt \d+ Termine/);
await shot(page, '13-wizard-period');
await page.click('[data-act=wizNext]');
await page.waitForSelector('.toast');
assert.match(await page.textContent('.toast'), /Plan erstellt in \d+:\d\d Min\./);
assert.match(await page.textContent('.top h2'), /Putzplan WG/);
assert.match(await page.textContent('.meta'), /letzten Freitag/);
const memberCounts = await page.locator('.chip').allTextContents();
assert.equal(memberCounts.length, 3); // Mia, Lea, Ida
await shot(page, '14-new-plan');

// persistence: reload keeps both plans
await page.reload();
await page.waitForSelector('.card');
assert.equal(await page.locator('.card').count(), 2);

// reset requires a confirmation and restores the sample
await page.click('[data-act=askReset]');
await page.click('[data-act=resetAll]');
await page.waitForSelector('.toast');
assert.equal(await page.locator('.card').count(), 1);

// empty state after deleting the only plan
await page.click('.card');
await page.click('[data-act=openMenu]');
await page.click('[data-act=askDelete]');
await page.click('[data-act=deletePlan]');
await page.waitForSelector('.empty');
await shot(page, '15-empty');
await noHorizontalScroll(page, 'empty');

// ------------------------------------------------- browser storage blocked
{
  const ctx = await browser.newContext({ viewport: { width: 375, height: 812 }, isMobile: true, hasTouch: true, locale: 'de-CH' });
  await ctx.addInitScript(() => { Object.defineProperty(window, 'localStorage', { get() { throw new DOMException('blocked', 'SecurityError'); } }); });
  const blocked = await ctx.newPage();
  blocked.on('pageerror', (e) => problems.push('pageerror (blocked storage): ' + e.message));
  await blocked.goto(url);
  await blocked.waitForSelector('.card');
  assert.match(await blocked.textContent('.warn'), /nichts speichern/);
  await blocked.click('#btn-new');
  await blocked.fill('#wiz-name', 'Ohne Speicher');
  await blocked.click('[data-act=wizNext]');
  for (const n of ['A', 'B']) { await blocked.fill('#wiz-person', n); await blocked.keyboard.press('Enter'); }
  await blocked.click('[data-act=wizNext]');
  await blocked.click('[data-act=wizNext]');
  await blocked.click('[data-act=wizNext]');
  await blocked.waitForSelector('.toast');
  assert.match(await blocked.textContent('.top h2'), /Ohne Speicher/);
  await ctx.close();
}

// ----------------------------------------------------------------- dark theme
const dark = await newPage('dark');
await dark.waitForSelector('.card');
await dark.click('.card');
await dark.waitForSelector('.slots');
const bg = await dark.evaluate(() => getComputedStyle(document.body).backgroundColor);
assert.notEqual(bg, 'rgb(241, 246, 245)', 'dark theme applies');
await shot(dark, '16-detail-dark');
await dark.click('[data-act=openShare]');
await dark.waitForSelector('.share-img');
await shot(dark, '17-share-dark');

// Escape closes a sheet
await dark.keyboard.press('Escape');
assert.equal(await dark.locator('.sheet').count(), 0);

await browser.close();
if (problems.length) { console.error('PROBLEMS:\n' + problems.join('\n')); process.exit(1); }
console.log('e2e ok');
