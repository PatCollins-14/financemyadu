// Builds landing/index.html from landing/index.src.html:
//  1. adds the selected reviews (names inside a review are hidden, like the funnel build)
//  2. joins the last two words of every text block with a no-break space (no orphan words)
//  3. fails on banned phrases (config/banned-phrases.json) and on any name of the program's source company
// Run: node landing/build.mjs
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
let html = fs.readFileSync(path.join(here, 'index.src.html'), 'utf8');

// ---- 1. reviews ----
// Picked for plain service quotes: no speed claims, no ratings, no numbers
const PICK = [2, 17, 16, 28, 42, 29];
const reviews = JSON.parse(read('src/data/reviews.json'));
const blur = JSON.parse(read('config/blur-names.json')).names.sort((a, b) => b.length - a.length);
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const PLATFORM = { bbb: 'BBB', birdeye: 'Birdeye', google: 'Google' };
function hideNames(text) {
  let out = esc(text);
  out = out.replace(/\[\[(.+?)\]\]/g, (_, n) => `\u0000${n.length}\u0000`);
  const reEsc = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  for (const n of blur) out = out.replace(new RegExp('(?<![A-Za-z>])' + reEsc(n) + '(?![A-Za-z])', 'g'), m => `\u0000${m.length}\u0000`);
  return out.replace(/\u0000(\d+)\u0000/g, (_, l) => `<span class="g-blur" aria-hidden="true">${'x'.repeat(+l)}</span><span class="sr">[name hidden]</span>`);
}
const cards = PICK.map(i => {
  const r = reviews.items[i];
  if (!r) throw new Error('missing review ' + i);
  return `<figure class="review"><blockquote>${hideNames(r.text)}</blockquote><figcaption><b>${esc(r.name)}</b> &middot; ${PLATFORM[r.p] || r.p} review${r.excerpt ? ' (excerpt)' : ''}</figcaption></figure>`;
}).join('\n      ');
html = html.replace('<!--REVIEWS-->', `<div class="reviews">\n      ${cards}\n    </div>\n    <p class="reviews-note">Selected reviews from BBB, Birdeye and Google about E Mortgage Capital and its loan officers. Names of staff inside reviews are hidden. The source sites also have other reviews.</p>`);

// ---- 2. no orphan words ----
const parts = html.split(/(<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>)/);
const TAGS = 'h1|h2|h3|h4|p|li|button|summary|figcaption|blockquote|dt|dd|a|span|small|div|em|strong|b';
const lastTwo = new RegExp('([^\\s<>;]+) ([^\\s<>&]+)(</(?:' + TAGS + ')>)', 'g');
for (let i = 0; i < parts.length; i += 2) parts[i] = parts[i].replace(lastTwo, '$1&nbsp;$2$3');
html = parts.join('');

// ---- 3. checks ----
const textOf = h => h.replace(/<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>/g, ' ').replace(/<!--[\s\S]*?-->/g, ' ')
  .replace(/<[^>]+>/g, ' ').replace(/&nbsp;/g, ' ').replace(/&middot;/g, '·').replace(/&amp;/g, '&').replace(/&#?\w+;/g, ' ').replace(/\s+/g, ' ');
// Dollar figures are allowed only inside the labeled hypothetical examples (data-scenario)
const scenarioFree = html.replace(/<article class="ex" data-scenario>[\s\S]*?<\/article>/g, ' ');
const banned = JSON.parse(read('config/banned-phrases.json'));
let body = textOf(html), bodyNoScenario = textOf(scenarioFree);
for (const ok of banned.allowedExact) { body = body.split(ok).join(' '); bodyNoScenario = bodyNoScenario.split(ok).join(' '); }
const problems = [];
for (const p of banned.patterns) {
  const hay = p.id === 'dollar-amount' ? bodyNoScenario : body;
  const m = hay.match(new RegExp(p.re, 'i'));
  if (m) problems.push(`${p.id}: "${m[0]}"`);
}
// Every trace of the company behind the program deck, checked in the whole file (markup, scripts, file names)
const SOURCE_NAMES = /reno\s*-?fi|quorum|qfcu|federal credit union|powered by|partners\.\w+\.org/i;
const hit = html.match(SOURCE_NAMES);
if (hit) problems.push(`source company name: "${hit[0]}"`);
if (/\[PAT:|DRAFT/i.test(textOf(html))) problems.push('visible placeholder or DRAFT text');
if (problems.length) { console.error('BUILD FAILED\n - ' + problems.join('\n - ')); process.exit(1); }

fs.writeFileSync(path.join(here, 'index.html'), html);
console.log('landing/index.html written,', Math.round(html.length / 1024), 'KB; checks passed');
