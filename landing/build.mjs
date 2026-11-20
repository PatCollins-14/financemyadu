// Builds landing/index.html from landing/index.src.html:
//  1. puts the LendingPad application link into every {{APPLY_URL}}
//  2. adds "(ARV)" after every "after renovation" / "after-renovation" in the page text
//     ("After-Renovation (ARV) HELOC", "after-renovation value (ARV)")
//  3. joins the last two words of every text block with a no-break space (no orphan words)
//  4. fails on: banned phrases (config/banned-phrases.json; dollar figures and percentages only inside
//     <article data-scenario>), any name of the program's source company, Pat's name outside the footer and
//     the advisor card, a missing "(ARV)", a leftover {{...}}, and any form or input (the page collects nothing)
// Run: node landing/build.mjs
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
let html = fs.readFileSync(path.join(here, 'index.src.html'), 'utf8');

// Runs fn on the page's text only: never inside tags (attributes), scripts, styles or comments
function onText(h, fn) {
  return h.split(/(<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>|<!--[\s\S]*?-->|<[^>]+>)/)
    .map((part, i) => (i % 2 ? part : fn(part))).join('');
}

// ---- 1. application link ----
// E Mortgage Capital LendingPad application (same link as the LTHM check funnel)
const APPLY_URL = process.env.APPLY_URL || 'https://prod.lendingpad.com/emci/38d77370-2060-489a-a024-4bdc8db0a865/pos#/';
html = html.split('{{APPLY_URL}}').join(APPLY_URL);

// ---- 2. (ARV) after every "after renovation" ----
const AFTER_RENO = /\b(after(?:-|&#8209;|‑|&nbsp;| )renovation)((?:\s|&nbsp;)+value)?(?!(?:\s|&nbsp;)*\(ARV\))(?!(?:\s|&nbsp;)+value(?:\s|&nbsp;)*\(ARV\))/gi;
html = onText(html, t => t.replace(AFTER_RENO, (m, a, v) => `${a}${v || ''}&nbsp;(ARV)`));

// ---- 3. no orphan words ----
const parts = html.split(/(<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>)/);
const TAGS = 'h1|h2|h3|h4|p|li|button|summary|figcaption|blockquote|dt|dd|a|span|small|div|em|strong|b';
// A "word" may contain numeric entities such as &#8209; (no-break hyphen), but never &nbsp;
const WORD = '(?:[^\\s<>&;]|&#\\d+;)+';
const lastTwo = new RegExp('(' + WORD + ') (' + WORD + ')(</(?:' + TAGS + ')>)', 'g');
for (let i = 0; i < parts.length; i += 2) parts[i] = parts[i].replace(lastTwo, '$1&nbsp;$2$3');
html = parts.join('');

// ---- 4. checks ----
const textOf = h => h.replace(/<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>/g, ' ').replace(/<!--[\s\S]*?-->/g, ' ')
  .replace(/<[^>]+>/g, ' ').replace(/&nbsp;/g, ' ').replace(/&middot;/g, '·').replace(/&amp;/g, '&').replace(/&#8209;/g, '-').replace(/&#?\w+;/g, ' ').replace(/\s+/g, ' ');
// Dollar figures and percentages are allowed only inside the labeled hypothetical examples (<article data-scenario>)
const scenarioFree = html.replace(/<article[^>]*data-scenario[^>]*>[\s\S]*?<\/article>/g, ' ');
const SCENARIO_ONLY = ['dollar-amount', 'percent'];
const banned = JSON.parse(read('config/banned-phrases.json'));
let body = textOf(html), bodyNoScenario = textOf(scenarioFree);
for (const ok of banned.allowedExact) { body = body.split(ok).join(' '); bodyNoScenario = bodyNoScenario.split(ok).join(' '); }
const problems = [];
for (const p of banned.patterns) {
  const hay = SCENARIO_ONLY.includes(p.id) ? bodyNoScenario : body;
  const m = hay.match(new RegExp(p.re, 'i'));
  if (m) problems.push(`${p.id}: "${m[0]}"`);
}
// Every trace of the company behind the program deck, checked in the whole file (markup, scripts, file names)
const SOURCE_NAMES = /reno\s*-?fi|quorum|qfcu|federal credit union|powered by|partners\.\w+\.org/i;
const hit = html.match(SOURCE_NAMES);
if (hit) problems.push(`source company name: "${hit[0]}"`);
// Pat's name only in the footer (licensing lines) and the advisor card; everywhere else the page says "your ADU loan advisor"
const noFooter = html.replace(/<footer[\s\S]*?<\/footer>/, ' ').replace(/<section[^>]*aria-labelledby="advisor-title"[\s\S]*?<\/section>/, ' ').replace(/<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>|<!--[\s\S]*?-->/g, ' ');
const pat = noFooter.match(/[^<>"]{0,40}\b(Pat|Collins)\b[^<>"]{0,40}/);
if (pat) problems.push(`Pat's name outside the footer: "${pat[0].trim()}"`);
// Every "after renovation" in the text carries (ARV)
const missingArv = textOf(html).match(/after[- ]renovation(?! value \(ARV\))(?! \(ARV\))[^.]{0,20}/i);
if (missingArv) problems.push(`"after renovation" without (ARV): "${missingArv[0]}"`);
if (/\[PAT:|DRAFT/i.test(textOf(html))) problems.push('visible placeholder or DRAFT text');
if (/\{\{\w+\}\}/.test(html)) problems.push('leftover template field: ' + html.match(/\{\{\w+\}\}/)[0]);
// The page collects nothing: no form and no input. The only actions are the application link, call and email.
if (/<form[\s>]|<input[\s>]|<textarea[\s>]|<select[\s>]/i.test(html)) problems.push('a form or input is on the page (this page collects nothing)');
if (problems.length) { console.error('BUILD FAILED\n - ' + problems.join('\n - ')); process.exit(1); }

fs.writeFileSync(path.join(here, 'index.html'), html);
console.log('landing/index.html written,', Math.round(html.length / 1024), 'KB; checks passed');
