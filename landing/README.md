# FinanceMyADU landing page (After ARV HELOC)

One static page. Actions: "Get Pre-qualified" (opens the LendingPad application), call or text (949) 787-2662, and an email link for plans or bids. No form, no server. Not deployed; financemyadu.io is offline (docs/DECISIONS.md D83 to D90).

## Files
- `index.src.html`: the page source (edit this one)
- `build.mjs`: run `node landing/build.mjs` after every edit. It writes `index.html` and:
  - puts the application link into every `{{APPLY_URL}}`
  - adds "(ARV)" after every "after renovation" / "after-renovation" in the text
  - joins the last two words of every text block (no orphan words)
  - fails on banned phrases, dollar figures or percentages outside `<article data-scenario>` blocks, the program source company's names, Pat's name outside the footer, a missing "(ARV)", a leftover `{{field}}`, or any form or input
- `index.html`: built page (do not edit by hand)
- `img/`: Higgsfield-generated 3D illustrations (WebP): hero, four ADU types, two renovation types
- `assets/`: Equal Housing Opportunity logo, favicons

## Application link
Set in `build.mjs` (`APPLY_URL`), or override when building: `set APPLY_URL=https://...&& node landing\build.mjs`

## Analytics
Google Tag Manager (`GTM-TQ8C7WLM`, in the `page-config` block) loads only after the visitor presses Accept. Clicks are pushed as `apply_click` with `cta_position` (hero, what, examples, advisor, final, sticky, header-call, advisor-call, advisor-plans, sticky-call).

## Preview locally
Any static file server pointed at `landing/`, for example the "fmadu-landing" entry in the Claude preview config (port 5181).
