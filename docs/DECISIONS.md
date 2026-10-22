# Decision log

Format: decision, reason, alternative considered.

**D1. Template = a copy of `adu-landing` (the page built earlier in this conversation).**
Reason: it is the only ADU page project in this conversation, it is plain static HTML (no client-only app, so stop condition (a) does not apply), and it was copied to `adu-geo-build` so the original stays untouched. Alternative: `C:\Users\keine\funnel-form` (the live `ask.patrickdcollins.com` site, with a git remote). Not used because it is a different product and is live. Also present in `adu-landing/` was an unrelated `adu-financing.html` ("Annex ADU Financing"). It makes claims ("low rates, no payments for 6 months, and nothing down") that break the compliance rules, so it was not used. Mention in the final report.

**D2. Build system is PowerShell 5.1 plus `run.cmd`, not npm.**
Reason: the template has no package manager; Node and Python are not installed; installing anything globally is forbidden. PowerShell ships with Windows. Alternative: ask to install Node (rejected: global install, stop-condition territory).

**D3. All content is rendered to static HTML at build time; JS is only progressive enhancement.**
Reason: the template rendered half its sections with JavaScript, which AI crawlers may not execute. Raw HTML must contain every heading, paragraph, disclosure and JSON-LD block.

**D4. Keep the template's design system (Playfair Display headings, Inter body, section bands, card patterns); re-point color tokens to the site's blues.**
Reason: the brief prefers the template's system. Site CSS blues (#52afe6, #354982, #223d78, #172338) are close to the template's blue family, so the pages read as one family. CTA color stays orange for contrast. Alternative: adopt Manrope / DM Sans from the site (rejected: extra rework, little benefit).

**D5. Hub canonical base = `https://letstalkhomemortgage.com` (subfolder) by default; switchable with `HUB_BASE_URL`.**
Reason: the brief names this the primary plan and asks for a config variable. Open question logged for Pat.

**D6. Funnel base = `https://financemyadu.io` (originally `https://myadufinancing.com` from the brief; changed by D19 and D20).**
Reason: domain named in the brief. Trade-name approval is an open `[PAT: ...]`.

**D7. Reverse mortgage card in the funnel comparison is gated by `SHOW_REVERSE_SECTION` (default false) together with the senior section.**
Reason: the brief gates the senior section; a reverse card alone would advertise the product without the required obligation text. Alternative: show a bare card (rejected).

**D8. DRE number shown as `[PAT: confirm DRE license number and label ...]` including the site's value as a hint, not as a fact.**
Reason: the site label is "BRE #02143449" and the BRE became the DRE; brief says use only after Pat confirms.

**D9. "30+ years" is used only as Pat's own statement from the build brief, with a source note; "realtor" and "reverse mortgage specialist" are not stated as credentials.**
Reason: the website says "decades in business, sales, real estate" and lists no real-estate license or designation.

**D10. Allow GPTBot by default (`ALLOW_GPTBOT=true`).**
Reason: the brief's stated default. It is a business choice that does not affect ChatGPT search inclusion (OAI-SearchBot). Open question logged.

**D11. X handle (@PCollinsLoan) is not used in `sameAs` structured data.**
Reason: only the handle appears on the site; the profile URL was not verified. Facebook page URL is verified from the footer.

**D12. HCD (hcd.ca.gov) and HUD pages returned HTTP 403 to automated reads; no workaround attempted.**
Reason: a block is the site's choice. Facts that depend on those pages are `[PAT: verify ...]` placeholders. CFPB, Fannie Mae and City of Pasadena pages were readable and are cited.

**D13. Percent and dollar figures are blocked by preflight with two documented per-page exceptions (Fannie Mae's 30% cap; scenario page assumptions).**
Reason: the brief's no-numbers rule, plus two pages that cannot work without one figure each. Both need compliance sign-off.

**D14. Hub pages that are not approved ship with a visible DRAFT banner; the reverse-mortgage page is also `noindex` until approved.**
Reason: brief section 8.2 and 8.3.

**D15. `FORM_ENDPOINT` must be set before production; preflight fails production when it is empty.**
Reason: never invent an endpoint; an unconnected form must not go live. This check is an addition to the brief's list.

**D16. DRE shown as "DRE #02143449" (Pat, chat 2026-10-23). Supersedes D8.**
Reason: Pat confirmed the number. The label "DRE" is used instead of the website's "BRE". Compliance should still confirm the label. Source noted in `docs/SOURCE-MAP.md`.

**D17. `ANALYTICS_ID` = `GTM-TQ8C7WLM`, reusing the main site's container (Pat, chat 2026-10-23).**
Reason: Pat's choice. Tracking is still off until a visitor accepts the consent bar, and the bar now says it uses Google Tag Manager and may set cookies. What tags the container fires is unverified (no access), so it is listed as a pre-launch check in `docs/MEASUREMENT.md`.

**D18. GPTBot allowed (Pat, chat 2026-10-23). Confirms D10.**

**D19. Trade name and domain are "FinanceMyADU" (Pat, chat 2026-10-23). Supersedes the brief's "MyADUFinancing". Approval is still pending.**
Reason: Pat stated it. `FUNNEL_BASE_URL`, the footer approval placeholder, the checklist and the ads prep were updated. The funnel page header shows only "ADU financing with Pat Collins", so the trade name appears only in the footer approval placeholder until approval is confirmed.

**D20. Funnel domain is `financemyadu.io` (Pat, chat 2026-10-23). Supersedes the `.com` assumed in D19.**
Reason: Pat gave the exact domain. Checked live: HTTP 200, robots.txt `User-agent: * / Disallow: /` (a parked blocking file, as the brief predicted). The build's robots.txt must replace it before ads run, or ChatGPT's ad review crawler may be blocked. Domain control is still for Pat to confirm.

**D21. Preview first, go-live later (Pat, chat 2026-10-23).**
Reason: the project is not live. Domain, DNS, form endpoint, GTM audit, GitHub, hosting, search tools and the ad account are parked in `docs/PAT-INPUTS.md` under "Parked until go-live". Dev builds now produce a local preview: `dist/index.html` (a noindex index of every page with status and open placeholder counts), hub links to the funnel and the hub breadcrumbs point at the local copies, and `run.cmd preview` builds and serves everything at http://localhost:8771/. Production builds are unchanged and still use absolute URLs.

**D22. Superseded by D24.** Pat first pointed to `adu-financing.html`, then to the Casita Works page; both rebuilds were discarded when Pat chose the Samara page (D24).
**D23. Lead form is name, email, phone and an optional plans upload only (Pat, chat 2026-10-23). Replaces the 4-step quiz.**
Reason: Pat's instruction ("no other stuff"). Consequences: (a) no consent checkbox; consent is a statement under the button with privacy and terms links, flagged for compliance, who may require a checkbox for text messages; (b) the form posts multipart/form-data so the plans file can upload, and the page checks each file against `UPLOAD_MAX_MB` (default 20, my choice, set it to the endpoint's real limit); (c) the upload is optional so homeowners without plans can still send the form; accepted types are PDF, images, CAD (DWG, DXF) and ZIP; (d) hidden UTM fields stay so ad clicks can be tied to leads (invisible to visitors); (e) the age, budget, value, balance, goal and timing questions are gone, so the funnel can no longer separate 62+ leads automatically; (f) preflight now fails if the form has any field other than name, email, phone, plans and the hidden UTM fields, or a select or checkbox.

**D24. Style, design, layout and inspiration come from https://www.samara.com/adus/financing (Pat, chat 2026-10-23). Supersedes D22.**
Reason: Pat's instruction. The page was opened and studied on 2026-10-23 (text, computed fonts and colours, and screenshots of every section). Adopted as a design language: floating wordmark with a centred translucent pill nav and a blue pill button; a huge light-weight headline with a dash list, a text link with an arrow and a hand-drawn line illustration; a bright blue band with one black card and one translucent card; a cream band with a large intro statement and a three-by-two grid of sketch-style features, then a centred pill button; a white comparison table with a black highlighted first column and check/cross marks; rounded photo-style tiles; a large-type link footer with the small print on the right. Palette: white, #0b78d1 blue (their blue is #0096f7; mine is darker so white text passes 4.5:1), cream #f7f7f0 and #fdfdf7, black. Typeface: Hanken Grotesk light (their typeface Regola is proprietary).
What was NOT taken from that page: any copy, "Backyard" or "Samara" names, rates, "what you could pay" figures, the payment calculator, "no payments for 6 months", "no money down", "100%" or "85%" claims, their licensing text, their photos and their illustrations. Artwork here is my own line art; the tiles use the isometric ADU art and dusk scenes already captured in `src/funnel/art/`. Everything is rewritten for a mortgage professional and stays inside the compliance rules.
How the Samara layout was adapted: the black card is the HELOC / home equity loan card and the translucent card is the cash-out refinance card, with a third card for renovation and construction loans and a gated fourth for reverse mortgages; the black table column is "Ask your lender" (one question per row) because there is no single product to highlight; the closing tiles jump to sections. Sections that page does not have but this project needs stay, restyled to match: identity row, how lenders look at an ADU, local proof, reviews, FAQ, and the lead form band.

**D25. Funnel headline changed to "Finance My ADU" with "& Renovations" in highlighted cursive (Pat, chat 2026-10-23). Replaces "Find the smartest way to pay for your ADU."**
Reason: Pat's instruction. Built as two lines on desktop (title line, then the cursive line on a yellow marker highlight, font Dancing Script 700 loaded from Google Fonts on the funnel only). On phones the headline scales with the screen (about 10% of the screen width, 32 px minimum) and neither line wraps, checked at 320 px and 375 px with no horizontal scroll. Markup keeps one `<h1>` whose text reads "Finance My ADU & Renovations".
Open issue: "& Renovations" implies renovation financing, which Pat's website does not list. A visible `[PAT: confirm you may advertise renovation financing; your site does not list it]` placeholder sits under the hero, and the high-risk row in `compliance/REVIEW-CHECKLIST.md` was updated. The page `<title>`, meta description and the ad copy still say "ADU financing"; say so if they should mention renovations too.
