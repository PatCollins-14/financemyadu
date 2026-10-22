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

**D6. Funnel base = `https://financemyadu.com` (originally `https://myadufinancing.com` from the brief; changed by D19).**
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
Reason: Pat stated it. The domain is assumed to be `financemyadu.com` (not stated explicitly; checked live, it answers 200). `FUNNEL_BASE_URL`, the footer approval placeholder, the checklist and the ads prep were updated. The funnel page itself shows only "ADU financing with Pat Collins" in its header, so the trade name appears only in the footer approval placeholder until Pat confirms approval.
