// FinanceMyADU landing page server. No dependencies (plain Node 18+).
// Serves landing/index.html and its assets, and takes leads at POST /api/lead:
// honeypot check -> Cloudflare Turnstile check (when keys are set) -> forward to the GHL webhook.
//
// Environment variables (set them in the host's panel, never in the repo):
//   GHL_WEBHOOK_URL       where leads go (required to send leads)
//   TURNSTILE_SITE_KEY    Cloudflare Turnstile site key  } both needed to switch the spam check on
//   TURNSTILE_SECRET_KEY  Cloudflare Turnstile secret    }
//   STUB_LEADS=1          log leads to the console instead of sending them (local testing)
//   PORT                  default 3000
'use strict';
const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const PORT = Number(process.env.PORT) || 3000;
const TYPES = { '.html': 'text/html; charset=utf-8', '.svg': 'image/svg+xml', '.png': 'image/png', '.ico': 'image/x-icon', '.css': 'text/css', '.js': 'text/javascript', '.txt': 'text/plain' };
// Only these paths are served; the source file, build script and this server are not
const PUBLIC = /^\/(index\.html|robots\.txt|art\/[\w.-]+\.svg|assets\/[\w.-]+\.(png|svg|ico))$/;

function send(res, code, body, type) {
  res.writeHead(code, { 'Content-Type': type || 'application/json', 'X-Content-Type-Options': 'nosniff', 'Referrer-Policy': 'strict-origin-when-cross-origin' });
  res.end(typeof body === 'string' || Buffer.isBuffer(body) ? body : JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let size = 0; const chunks = [];
    req.on('data', c => { size += c.length; if (size > 20000) { reject(new Error('too large')); req.destroy(); } else chunks.push(c); });
    req.on('end', () => { try { resolve(JSON.parse(Buffer.concat(chunks).toString('utf8') || '{}')); } catch (e) { reject(e); } });
    req.on('error', reject);
  });
}

async function turnstileOk(token, ip) {
  const secret = process.env.TURNSTILE_SECRET_KEY;
  if (!secret || !process.env.TURNSTILE_SITE_KEY) return true; // check is off until both keys are set
  if (!token) return false;
  const r = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ secret, response: token, remoteip: ip || '' })
  });
  const j = await r.json().catch(() => ({}));
  return !!j.success;
}

const FIELDS = ['name', 'email', 'phone', 'consent', 'consent_text', 'form_name', 'page_url', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'gclid', 'fbclid'];

async function handleLead(req, res) {
  let data;
  try { data = await readBody(req); } catch (e) { return send(res, 400, { ok: false, error: 'bad_request' }); }
  if (data.company_website) return send(res, 200, { ok: true }); // honeypot: pretend it worked, send nothing
  const name = String(data.name || '').trim(), email = String(data.email || '').trim(), phone = String(data.phone || '').replace(/\D/g, '');
  if (name.length < 2 || !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email) || phone.replace(/^1/, '').length !== 10 || data.consent !== true) {
    return send(res, 422, { ok: false, error: 'invalid' });
  }
  const ip = String(req.headers['cf-connecting-ip'] || req.headers['x-forwarded-for'] || req.socket.remoteAddress || '').split(',')[0].trim();
  if (!(await turnstileOk(data.turnstile_token, ip))) return send(res, 403, { ok: false, error: 'spam_check' });

  const lead = {};
  for (const k of FIELDS) if (data[k] !== undefined && data[k] !== '') lead[k] = typeof data[k] === 'string' ? data[k].slice(0, 2000) : data[k];
  lead.submitted_at = new Date().toISOString();

  if (process.env.STUB_LEADS === '1') { console.log('[stub] lead not sent:', JSON.stringify(lead)); return send(res, 200, { ok: true, stub: true }); }
  const hook = process.env.GHL_WEBHOOK_URL;
  if (!hook) { console.error('GHL_WEBHOOK_URL is not set; lead dropped'); return send(res, 503, { ok: false, error: 'not_configured' }); }
  try {
    const r = await fetch(hook, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(lead) });
    if (!r.ok) throw new Error('webhook ' + r.status);
    return send(res, 200, { ok: true });
  } catch (e) {
    console.error('lead forward failed:', e.message);
    return send(res, 502, { ok: false, error: 'forward_failed' });
  }
}

http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://x');
  if (url.pathname === '/api/lead' && req.method === 'POST') return handleLead(req, res);
  if (url.pathname === '/api/lead-config') return send(res, 200, { turnstileSiteKey: process.env.TURNSTILE_SECRET_KEY ? (process.env.TURNSTILE_SITE_KEY || '') : '' });
  if (url.pathname === '/api/health') return send(res, 200, { ok: true, webhook: !!process.env.GHL_WEBHOOK_URL, turnstile: !!(process.env.TURNSTILE_SITE_KEY && process.env.TURNSTILE_SECRET_KEY), stub: process.env.STUB_LEADS === '1' });
  if (req.method !== 'GET' && req.method !== 'HEAD') return send(res, 405, { ok: false });
  const p = url.pathname === '/' ? '/index.html' : url.pathname;
  if (!PUBLIC.test(p)) return send(res, 404, 'Not found', 'text/plain');
  fs.readFile(path.join(ROOT, p), (err, buf) => {
    if (err) return send(res, 404, 'Not found', 'text/plain');
    send(res, 200, req.method === 'HEAD' ? '' : buf, TYPES[path.extname(p)] || 'application/octet-stream');
  });
}).listen(PORT, () => console.log('FinanceMyADU landing on http://localhost:' + PORT));
