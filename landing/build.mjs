// Builds landing/index.html from landing/index.src.html:
//  1. puts Pat's application link (LendingPad) into every {{APPLY_URL}}
//  2. joins the last two words of every text block with a no-break space (no orphan words)
//  3. fails on banned phrases (config/banned-phrases.json; dollar figures and percentages only inside <article data-scenario>), on any name of the program's source company,
//     on a leftover {{...}} and on any form (the page collects nothing; the only action is the application link)
// Run: node landing/build.mjs
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
let html = fs.readFileSync(path.join(here, 'index.src.html'), 'utf8');

// ---- 0. application link ----
// Pat Collins' E Mortgage Capital LendingPad application (same link as the LTHM check funnel)
const APPLY_URL = process.env.APPLY_URL || 'https://prod.lendingpad.com/emci/38d77370-2060-489a-a024-4bdc8db0a865/pos#/';
html = html.split('{{APPLY_URL}}').join(APPLY_URL);

// ---- 2. no orphan words ----
const parts = html.split(/(<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>)/);
const TAGS = 'h1|h2|h3|h4|p|li|button|summary|figcaption|blockquote|dt|dd|a|span|small|div|em|strong|b';
const lastTwo = new RegExp('([^\\s<>;]+) ([^\\s<>&]+)(</(?:' + TAGS + ')>)', 'g');
for (let i = 0; i < parts.length; i += 2) parts[i] = parts[i].replace(lastTwo, '$1&nbsp;$2$3');
html = parts.join('');

// ---- 3. checks ----
const textOf = h => h.replace(/<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>/g, ' ').replace(/<!--[\s\S]*?-->/g, ' ')
  .replace(/<[^>]+>/g, ' ').replace(/&nbsp;/g, ' ').replace(/&middot;/g, '·').replace(/&amp;/g, '&').replace(/&#?\w+;/g, ' ').replace(/\s+/g, ' ');
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
if (/\[PAT:|DRAFT/i.test(textOf(html))) problems.push('visible placeholder or DRAFT text');
if (/\{\{\w+\}\}/.test(html)) problems.push('leftover template field: ' + html.match(/\{\{\w+\}\}/)[0]);
if (/<form[\s>]|<input[\s>]/i.test(html)) problems.push('a form or input is on the page (this page links to the application instead)');
if (problems.length) { console.error('BUILD FAILED\n - ' + problems.join('\n - ')); process.exit(1); }

fs.writeFileSync(path.join(here, 'index.html'), html);
console.log('landing/index.html written,', Math.round(html.length / 1024), 'KB; checks passed');
