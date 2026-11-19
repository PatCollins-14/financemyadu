# FinanceMyADU landing page (After-Renovation HELOC)

One static page. The only action is "Get Pre-qualified", which opens Pat Collins' LendingPad application. No form, no server. Not deployed; financemyadu.io is offline (see docs/DECISIONS.md D83 to D86).

## Files
- `index.src.html`: the page source (edit this one)
- `build.mjs`: run `node landing/build.mjs` after every edit. Puts the application link into every button, adds the reviews, joins last words, and fails on banned phrases, stray dollar figures, source-company names, leftover {{fields}} or any form
- `index.html`: built page (do not edit by hand)
- `art/`, `assets/`: ADU drawings, Equal Housing Opportunity logo, favicons

## Application link
Set in `build.mjs` (`APPLY_URL`), or override when building: `set APPLY_URL=https://...&& node landing\build.mjs`

## Analytics
Google Tag Manager (`GTM-TQ8C7WLM`, in the `page-config` block) loads only after the visitor presses Accept. Button clicks are pushed as `apply_click` with `cta_position` (header, hero, what, final, sticky).

## Preview locally
Any static file server pointed at `landing/`, for example the "fmadu-landing" entry in the Claude preview config (port 5181).
