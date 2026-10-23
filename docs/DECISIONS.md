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

**D26. Renovation financing is offered (Pat, chat 2026-10-23: "I do renovations. So do it in our plans"). Resolves the open issue in D25 and loosens CLAUDE.md rule 3.**
Reason: Pat confirmed it. Changes made: the "confirm you may advertise renovation financing" placeholder is gone; the funnel hero list, renovation card, comparison note and a new FAQ entry now say Pat helps homeowners finance renovations; the funnel title tag and meta description now read "ADU & Renovation Financing in California | Pat Collins"; the hub renovation page lost its "educational only" callout and gained a section on combining an ADU with other renovation work; the hub FAQ gained the same question; two ad variants were added (T7, D7). The unnamed-programs rule stays: no specific loan program (HomeStyle, FHA 203(k) or any other) is named as Pat's until Pat supplies it, so one narrower placeholder, "which renovation and construction programs you offer", remains in the funnel, the pillar page and the renovation page. The hub still has no page that is only about renovations without an ADU; say if you want one.

**D27. The funnel form moves into the hero and the file upload is removed everywhere (Pat, chat 2026-10-24). Supersedes the upload parts of D23.**
Reason: Pat's instruction. The hand-drawn house in the hero's right-hand slot is replaced by the lead form (full name, email, phone; three visible fields; four hidden UTM fields). On wide screens the form sits beside the headline and spans the hero's full height; on tablets and phones it follows the headline directly. The hero headline is slightly smaller on desktop (about 5.4% of the screen width, max 80 px) so the two-line title fits next to the form without overlap, checked at 1240, 1024 and 375 px. The lower cream band no longer holds a second form: it is now "How it works" (three steps) next to a "Prefer to talk first?" card with Book a call, Call, Email and the application-link placeholder, and a link back up to the form (all "See my financing options" buttons and links point to the hero form, `#apply`).
What was removed for the upload: the file field, the size check and its config (`UPLOAD_MAX_MB`), the script code for it, the multipart encoding (the form posts normally again, urlencoded), the copy about sending plans ("Send your existing plans...", step 1 wording, the upload icon), and the compliance-checklist row about stored plans. Preflight now fails if the form has a file input or multipart encoding. Hub pages still tell homeowners to ask lenders what plans they need; that is advice, not an upload.

**D28. Headline restyled (Pat, chat 2026-10-24): "& Renovations" is smaller than "Finance My ADU", the yellow highlight box is removed, and the "&" has its own color.**
"Finance My ADU" stays light-weight Hanken Grotesk. "Renovations" is Dancing Script 700 in near-black at 70% of the first line's size (82% on phones, so it stays readable at 32 px). The "&" is the same cursive in the page blue (#0b78d1, 4.8:1 on white) at 120% of the second line's size, as a single accent. No underline, box or background. Still one `<h1>` reading "Finance My ADU & Renovations"; checked at 1240, 375 and 320 px, two lines, no wrapping or horizontal scroll.

**D29. Boxed rental-income disclaimer and the investor-loan (DSCR) paragraph removed from the funnel's "How lenders look at an ADU" section (Pat, chat 2026-10-24).**
Removed: the callout box "Rental income is not guaranteed and may not count toward qualification under every program." and the paragraph about investor loans and Pat's Non-QM page, including its `[PAT: confirm which programs you offer that consider ADU rental income or after-ADU value]` placeholder. The section now has two paragraphs (programs may or may not consider projected rent or after-ADU value; Fannie Mae's rule for one existing ADU) and its source line. The non-QM source is no longer cited by the funnel.
Compliance note: the brief (section 10, rule 2) asks ADU pages to carry the line "Rental income is not guaranteed and may not be counted for qualification under every program." It is still in the funnel footer and in the FAQ answer about rental income, and on the hub pages. If compliance wants it prominent near the rental-income text, it can be put back. The programs question is still open in the funnel FAQ and the rental-income hub page.

**D30. Footer "More" column simplified (Pat, chat 2026-10-24).**
The HELOC and Refinance links are replaced by one link, "Mortgages", to the LetsTalkHomeMortgage.com home page (`siteLinks.home`). The column is now "Mortgages" and "Articles". Applies to the funnel and every hub page, since they share `Get-Footer`. No other footer changes.

**D31. "Let's Talk Home Mortgage" breadcrumb is no longer a link (Pat, chat 2026-10-24).**
On every hub page the first breadcrumb item shows as plain text, with no destination. The other crumbs still link. The page's BreadcrumbList JSON-LD still lists the item with its URL (schema needs it), so the visible text and the structured data still match.

**D32. Terms & Conditions link set to https://letstalkhomemortgage.com/terms/ (Pat, chat 2026-10-24).**
Pat confirmed this is the right page. It replaces `/terms-and-conditions/` in the footer of the funnel and every hub page, and in the `terms_url` data used for the form's consent text. Changed in `scripts/make-identity.ps1` and `src/data/identity.json`. Dated compliance snapshots and the raw source extract keep the old URL, because they record what was captured at the time. The Privacy Policy link is unchanged (`/privacy-policy/`); the live site has two versions of that page too (see SITE-ISSUES item 12).

**D33. Colours changed to the Let's Talk Home Mortgage brand, still light mode (Pat, chat 2026-10-24).**
Read from the live site (read-only): navy #223d78, sky blue #399cda / #52afe6, gold #f0b82e to #dfa529 with dark ink text, deep ink #101827. Applied to `src/assets/site.css` only, as tokens, so the funnel and all hub pages change together. Page background stays white; the old cream tint is now a light sky tint (#f1f6fc).
- Buttons: gold gradient with dark text and 12 px corners (as on the live site's "Get Preapproved"). Ghost buttons are white with a navy label.
- Headline "&" is sky blue (#1f86cf, large text). Links are #1a6fb0 (5.3:1 on white).
- Large bands (options band, comparison highlight column, hub call-to-action) use a lighter navy (#2c4d95, white text 8:1) with a soft sky glow, instead of black or deep blue, so the page stays bright.
- Header gets a thin sky-to-gold line (echoing the live site's header); form card and hub answer box get a gold top/left accent; footer gets a navy top rule and navy links.
- Placeholder highlights stay yellow but now carry a dashed outline so they cannot be mistaken for brand gold.
- Fonts unchanged (Hanken Grotesk, with Dancing Script for the "& Renovations" line). The live site itself uses Space Grotesk and DM Sans; if Pat wants those instead, it is a one-line change.

**D34. Booking link set to the RAD CRM calendar (Pat, chat 2026-10-24).**
Every "Book a call" / "Book a time to talk" link now goes to https://link.theradcrm.com/widget/booking/urhkr4DnMJd8JiUmcmJJ. Set once as `BOOKING_URL` in `config/site.json` (replaces check.letstalkhomemortgage.com); the funnel contact card, the footer on every page and the About Pat page all read it. It can still be overridden with the `BOOKING_URL` environment variable. The "Booking link" row in the identity table still shows the old live-site link, because it records what the live site says. The third-party calendar is Pat's own booking widget; compliance may want to confirm it is listed with the other vendors that see visitor data.

**D35. Gold buttons use white text (Pat, chat 2026-10-24).**
Every gold button (header "See my options", form submit, "Book a call", cookie "Accept", mobile bar "See options", hub buttons) now has white text with a faint warm shadow for legibility. White-on-gold contrast is about 1.9:1, below the 4.5:1 WCAG AA target for text of this size; Pat asked for it knowingly. If compliance or accessibility review objects, the one-line fix is to set `.btn` and `.mbar .est` colour back to `var(--ink)` in `src/assets/site.css`. White buttons on navy bands and the white-outline "Call" buttons are unchanged.

**D36. Privacy Policy link set to https://letstalkhomemortgage.com/privacy/ (Pat, chat 2026-10-24).**
Replaces `/privacy-policy/` in the footer of the funnel and every hub page and in the form's consent text. Changed in `scripts/make-identity.ps1` and `src/data/identity.json`. With D32 (Terms at `/terms/`) both legal links now match the live site's own footer, which closes SITE-ISSUES item 12 for our pages.

**D37. Funnel reviews are now Google reviews in the live site's card style (Pat, chat 2026-10-24).**
The review cards copy the layout of the Let's Talk Home Mortgage review section (star row, source badge, short text, initials avatar with name and date), in light mode with the new brand colours. The source is Google instead of BBB: the six BBB cards, the BBB link and the "from BBB" label are gone from the funnel.
Content: opened E Mortgage Capital, Inc. in Google Maps on 2026-10-24 (read-only): 4.7 stars, 3,692 reviews, and the three reviews Google would show (all 5 stars). Each card is a short summary written by us, not a quote, as the live site does; reviewer shown as first name and last initial; loan officers' names left out; Google gives only relative dates ("3 months ago"). Data in `src/data/google-reviews.json`; the Google profile is in SOURCE-MAP.
Cautions: (1) the rating and count belong to E Mortgage Capital as a whole and will change; the text says so and says the reviews are not specific to ADU financing or to Pat alone. (2) One review was about a reverse mortgage; its card leaves the product out because the reverse-mortgage content is gated off, so compliance should look at it. (3) A visible placeholder asks Pat to confirm he may show these reviews and which to feature. Only three were visible, so the grid has three cards instead of six.

**D38. Reviews become a sideways carousel of 15 Google cards, with the live site's header (Pat, chat 2026-10-24). Updates D37.**
- Layout copied from the Let's Talk Home Mortgage review section: gold "Customer experience" kicker, the title "A clear mortgage process should create a better experience." (Pat's own site copy, blue italic part), a score badge, "See what customers are saying across the web." with tiles linking to the Google, Yelp, Zillow and BBB review pages, then a carousel with arrows and dots. The text is no longer Google-only; only the cards are Google. Tiles use the platform names, not the logo images from the live site: those images carry their own review counts ("1915+ Reviews" on the Google one), which would conflict with Google's current 3,692.
- Cards are equal height and width; the author row is pinned to the bottom. Three cards show at once on desktop, two on tablets, one and a peek on phones; arrows, dots, swipe and the keyboard arrow keys work, and without JavaScript the row still scrolls sideways.
- Content: opened the Google reviews list for E Mortgage Capital, Inc. in the browser on 2026-10-24 (190 loaded; 164 were 5-star, 21 were 1-star). Picked 15 5-star reviews about refinance, cash-out, HELOC and home purchase, each summarised by us (no quotes). Left out: reverse-mortgage reviews, VA and investor reviews, reviews that mention debt, rates or speed, and all loan-officer names. Shown as first name and last initial. The section says these are selected 5-star reviews and that the 4.7 counts every review; about 11% of the 190 were 1-star, so compliance should decide whether a selection is acceptable.
- Profile pictures: not used. Google reviewers are private people and Google shows their photos under Google's terms; copying them onto Pat's page is a privacy and permission question. Coloured initials are used instead (what the live site does and what Google shows for people without a photo). If Pat wants photos, it needs each reviewer's permission, or Google's own embeddable review widget.
- Data: `src/data/google-reviews.json`. Build: `scripts/build.ps1`. Script: the carousel block in `src/assets/quiz.js`.

**D39. Booking link changed to Pat's named appointment page (Pat, chat 2026-10-24). Replaces D34's address.**
Every "Book a call" / "Book a time to talk" link now goes to https://link.theradcrm.com/widget/bookings/appointment-booking-with-pat-collins. Still one setting, `BOOKING_URL` in `config/site.json`.

**D41. Photos of Pat removed again (Pat, chat 2026-10-24: "Looks bad. Undo it").**
The headshot (hero and About Pat page) and the consultation photo ("Prefer to talk first?" card) added in D40 were reverted; the funnel and hub are back to their previous look, with the About page's "[PAT: ... a headshot with alt text]" placeholder restored. Done with `git revert` of the D40 commit, so it can be brought back. The D40 note about the AI image accounts (Higgsfield and Magnific at 0 credits) and the stock searches (no usable California ADU photos) still stands.
