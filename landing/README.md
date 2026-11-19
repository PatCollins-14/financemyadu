# FinanceMyADU landing page (After-Renovation HELOC)

One page, one call to action ("Get Pre-qualified"). Not deployed; financemyadu.io is offline (see docs/DECISIONS.md D83 to D85).

## Files
- `index.src.html`: the page source (edit this one)
- `build.mjs`: run `node landing/build.mjs` after every edit. Writes `index.html`, adds the reviews, joins last words, runs the compliance and company-name checks
- `index.html`: built page (do not edit by hand)
- `server.js`: serves the page and takes leads at `POST /api/lead`
- `art/`, `assets/`: ADU drawings, Equal Housing Opportunity logo, favicons

## Run locally (no lead is sent)
```
set STUB_LEADS=1&& set PORT=5181&& node landing\server.js
```
Open http://localhost:5181/. Submitted leads are printed in the console.

## Environment variables on the host (never in the repo)
| Name | What |
|---|---|
| `GHL_WEBHOOK_URL` | GoHighLevel webhook that receives the leads (required) |
| `TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET_KEY` | Cloudflare Turnstile; the spam check is on only when both are set |
| `PORT` | Port the host assigns |

`GET /api/health` shows whether the webhook and Turnstile are set.

## Lead fields sent to the webhook
name, email, phone, consent (true), consent_text, form_name ("FinanceMyADU - After-Renovation HELOC landing"), page_url, utm_source, utm_medium, utm_campaign, utm_term, utm_content, gclid, fbclid, submitted_at.

## Page settings
In `index.src.html`, the `page-config` JSON block holds the lead endpoint, booking link, Google Tag Manager id (loads only after the visitor presses Accept) and the default campaign name.
