// Writes docs/curseforge/<Addon>.html from kit.html (the CurseForge description of every addon).
// node docs/curseforge/export.js   (needs playwright)
const { chromium } = require('playwright');
const fs = require('fs'), path = require('path');
(async () => {
  const dir = __dirname;
  const b = await chromium.launch(); const p = await b.newPage();
  await p.goto('file://' + path.join(dir, 'kit.html'));
  const out = await p.evaluate(() => { const o = {}; for (const a of (typeof ADDONS !== 'undefined' ? ADDONS : APPS)) o[a.name] = descHtml(a); return o; });
  for (const [name, html] of Object.entries(out)) fs.writeFileSync(path.join(dir, name + '.html'), html);
  console.log(Object.keys(out).join(', '));
  await b.close();
})();
