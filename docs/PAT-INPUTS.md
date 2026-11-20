# What Pat still needs to supply

Status key: [x] filled from the website (verified live 2026-10-23), [ ] open. Every open item is a visible `[PAT: ...]` placeholder in the pages. Preflight blocks production while any remain.

## Filled from letstalkhomemortgage.com (verified live)
- [x] Individual NMLS #1628553; company E Mortgage Capital Inc., NMLS #1416824; address 3750 S. Susan Street, Santa Ana, CA 92704
- [x] Phone (949) 787-2662, email pcollins@emortgagecapital.com, booking link, Facebook page, NMLS Consumer Access link
- [x] Core product list (purchase, refinance, HELOC / home equity loan, reverse mortgage, Non-QM)
- [x] About Pat statements, audiences, principles, process steps, FAQ text, footer disclosure text, brand assets
- [x] Six BBB review summaries (E Mortgage Capital)
- Differences found vs the seed copy: 18 articles (not 8); four spam-style posts in the post sitemap; the footer links /dti-calculator/ which returns 404. See `docs/SITE-ISSUES.md`.

## Parked until go-live (Pat, 2026-10-23: "set those aside")
These need accounts, DNS or a live site, so they wait until after the initial preview. Nothing in the preview depends on them.
- Domain: confirm you control financemyadu.io, point DNS at the deployed funnel, and replace its parked `Disallow: /` robots.txt with this build's
- `FORM_ENDPOINT` (ADU qualifier form or other endpoint) and the campaign application link (`APPLICATION_URL`). The endpoint receives a normal form post: name, email, phone and four hidden UTM fields.
- Google Tag Manager: list the tags in container GTM-TQ8C7WLM and confirm the consent bar wording covers them
- GitHub repo, workflow and hosting (see the chat; the project is already a git repo, nothing pushed)
- Search Console, Bing Webmaster Tools, the ChatGPT ad account and ad approval (`ads/chatgpt-ads-prep.md`)
- Hub location decision (subfolder vs subdomain) and pasting `hub/wordpress-ready/` into WordPress
- Running the production gate (`run.cmd production`), which needs every page APPROVED

## Still needed (most important first)
- [ ] **Compliance contact and process at E Mortgage Capital**, and sign-off in `compliance/REVIEW-CHECKLIST.md`
- [x] **DRE #02143449**, confirmed by Pat in chat 2026-10-23. The website footer still labels it "BRE", so compliance should confirm the label
- [ ] **ADU qualifier form or `FORM_ENDPOINT`**; confirm the application link for this campaign (`APPLICATION_URL`)
- [ ] **"FinanceMyADU" approved as a trade name** for E Mortgage Capital (name supplied by Pat 2026-10-23; approval pending). Domain: financemyadu.io (Pat, 2026-10-23). Also confirm you control it; it currently serves a parked page that blocks crawlers
- [x] **Renovation financing: yes** (Pat, chat 2026-10-23: "I do renovations")
- [ ] **Which renovation and construction programs you offer** (names, what each can include, how an ADU plus other renovation work can be combined, draws and inspections)
- [ ] **Which programs you offer** that consider ADU rental income or after-ADU value
- [ ] **Lender of record and required disclosures for reverse mortgages** (site names Finance of America Reverse LLC); confirm whether to show the reverse mortgage section (`SHOW_REVERSE_SECTION`) and verify HECM rules for funding an ADU
- [ ] **Confirm "no obligation" and "no credit check"** statements, and approved text-message consent wording
- [ ] **Real ADU financing scenarios** (with permission): numbers as ranges, what went wrong or surprised you; one "What I see in real ADU financing" block per hub page
- [ ] **Headshot and fuller bio**; confirm "30+ years" wording; confirm any real estate license or reverse mortgage designation you want stated
- [ ] **Verified Pasadena and California ADU facts**: the City of Pasadena ADU page is cited; HCD and HUD pages blocked automated reads, so any state-law fact needs a verified source or your approval to cite one
- [ ] **Hub location:** subfolder of LetsTalkHomeMortgage.com or a subdomain (`HUB_BASE_URL`); WordPress exports are in `hub/wordpress-ready/`
- [x] **Analytics:** reuse GTM-TQ8C7WLM (Pat, chat 2026-10-23), set as `ANALYTICS_ID`. Still open: confirm which tags that container fires and that the consent bar wording covers them
- [x] **GPTBot: allow** (Pat, chat 2026-10-23; does not affect ChatGPT search)
- [ ] Reviews under your own name (source and permission), or confirmation to rely on the E Mortgage Capital reviews only
- [ ] Reviews on the funnel: Pat supplied 44 exact customer quotations and excerpts (6 BBB, 26 Birdeye, 12 Google shown on Birdeye officer pages; compiled 2026-10-27) in `src/data/reviews.json`, shown in random-balanced order on each load. Compliance to approve them, including wording that speaks to speed ("less than 30 days", "Early Closing, Fast Respond", "timely manner", "quickly closed") and positive-only selection. Staff names inside the text and in the "Reviewed:" lines are hidden automatically (`config/blur-names.json`). No ratings, counts or numbers are shown.
- [ ] Confirm whether to show the worked example (`SHOW_EXAMPLE`; needs lender-approved disclosures) and supply its numbers
- [ ] Real profile URLs for structured-data `sameAs` (X, YouTube, LinkedIn, Google Business Profile); confirm the AIME badge may be shown
- [ ] Wait-time, equity-explanation and process wording marked in pages as `[PAT: ...]`

## New landing page: After-Renovation HELOC (`landing/`, built 2026-11-20)
Source: the program deck Pat was referred to ("ARV HELOC-Deck 7_2025.pdf", 20 pages, broker-facing). The page shows none of the source company's names, logos, website, contacts or partner lines (build check in `landing/build.mjs`).

### Needed before it goes live
Since 2026-11-20 (D86) the page has no form: every "Get Pre-qualified" button opens Pat's LendingPad application. The page is static and needs no server, webhook or spam keys.

- [ ] **Compliance sign-off** at E Mortgage Capital for the whole page, especially the two hypothetical examples (they show home values, a mortgage balance and project budgets as assumptions, with no rate, payment or term) and the comparison table (renovation mortgages, cash-out refinance, standard HELOC).
- [ ] **Confirm Pat can offer this program** through E Mortgage Capital as the broker of record (the deck is written for wholesale partners), and whether the lender must be named in a disclosure.
- [ ] **Confirm the application link** is Pat's own: `https://prod.lendingpad.com/emci/38d77370-2060-489a-a024-4bdc8db0a865/pos#/` (taken from the LTHM check funnel's "apply" link). LendingPad showed "Not available in your region" to this computer, so open it once from a US connection to be sure it loads. To change it, set `APPLY_URL` in `landing/build.mjs` (or as an environment variable) and rebuild.
- [ ] **Lead tracking:** the page itself no longer creates a GHL contact. Leads reach GHL only when the LendingPad application syncs (the "Loan Updated" Zap). Visitors who click but don't finish the application are not captured; GTM counts the clicks (`apply_click`) after cookie consent.
- [ ] **Hosting:** static files only, so GitHub Pages (the repo's existing setup) works again; publish `landing/` as the site root when going live. Decide host, then DNS (D84 has the steps to turn Pages back on).
- [ ] **Page name:** "After-Renovation HELOC" is a plain description used in place of the deck's product name. Confirm it is fine to use, or give the name you want.
- [ ] Optional: a headshot of Pat and a line about him; real ADU projects done with this program (with permission) to sit beside the hypothetical examples.

### Kept off the page on purpose (numbers and claims from the deck)
| From the deck | Why it is not on the page |
|---|---|
| Rates = Prime plus a FICO/CLTV adjustment | Rate talk without disclosures; covered one to one |
| Project supervision fee of $149 a month after closing | Dollar figure and a per-month cost. The FAQ says supervision has its own fee and Pat goes over every cost up front. Disclose it in the first call |
| Borrower-paid compensation up to 4% | Broker compensation, not for the consumer page |
| "11x more borrowing power on average" | Unverified average across the program. The page shows the same property ($400K home) worked out instead, without the "11x" claim |
| "Only HELOC based on ARV on the market" | Unverifiable superlative |
| "Close fast", "quicker process", "get them in the property fast" | Speed claims are flagged by compliance ("fast" wording) |
| "Can refi down the road", "frees up cash to invest elsewhere" | Future refinance and investment talk invite promises the page can't make |
| "Can exceed FNMA loan limit, jumbo renovation" | Loan-size claim |
| Realtor and contractor pitches ("makes your client a cash buyer", "cut out the bank") | Aimed at partners, not homeowners. Could become separate partner pages later |

### Numbers that are on the page (need compliance sign-off)
Since D87 (Pat, 2026-11-20: "add example breakdowns and example properties just like in the PDF") the page shows the deck's worked math for three example properties, inside cards labeled "Example property" with a hypothetical-example notice. The build allows dollar figures and percentages only inside those cards and the formula box above them (`<article data-scenario>`).
- Formula box: standard HELOC = today's value × the lender's limit (80% to 85% in the examples) minus the first mortgage; After-Renovation HELOC = the lesser of 95% of the finished value or 125% of today's value, minus the first mortgage.
- Property 1 (deck slide 11): value $400,000, first mortgage $315,000, project $100,000, value after $500,000. Standard at 80%: $5,000. After-renovation: lesser of $185,000 and $160,000 = $160,000.
- Property 2 (deck slide 15): value $725,000, first mortgage $600,000, project about $250,000, value after $950,000. Standard at 85%: $16,250. After-renovation: lesser of $306,250 and $302,500 = $302,500.
- Property 3 (deck slide 16): purchase price and value $500,000, first mortgage $475,000, project $100,000, value after $650,000. Standard at 85%: $0 (added for comparison; the deck shows only the after-renovation side). After-renovation: lesser of $150,000 and $142,500 = $142,500; the buyer takes $100,000.
These "most you could borrow" figures and the CLTV percentages are not Reg Z HELOC trigger terms (those are payment terms, APR and fees, none of which appear), but they are maximum line amounts and loan-to-value limits, which this project blocks by default. Compliance must approve them before launch. The 95% and 125% limits come from the deck (July 2025) and can change.

### Added at Pat's request on 2026-11-21 (D89): compliance must clear these before launch
Pat asked for these by name. They are now on the page, so the earlier "kept off" reasons for them no longer apply:
- **Interest-only payments for the 10-year draw period, then 20-year repayment** (hero, "What it is", FAQ). These are HELOC *payment terms*, which are Regulation Z advertising trigger terms (12 CFR 1026.16(d)). An ad that states them must also give the required disclosures: the APR (for a variable-rate line, the index and margin, and that the rate can change), any fees for opening the plan, the maximum APR (rate cap) and any balloon payment. The page cannot state those because they aren't known here (the deck only says "Prime + FICO/CLTV adjustment"). The footer now says interest-only payments don't reduce the balance and that payments rise when repayment starts, but **that is not the full Reg Z disclosure**. Either compliance supplies the disclosure text and Pat adds it, or the payment terms come back off the page.
- **Exact program numbers in "Who qualifies"**: $500,000 up to 95% CLTV, $750,000 up to 65% CLTV, $50,000 minimum project, 640+ credit, full-doc income, 43% DTI (45% with 720+). From the July 2025 deck; they can change.
- **"3%" first-mortgage rate (example 2) and "5% down" (example 3)**. The 3% is the borrower's existing loan, not an offer. "5% down" describes the purchase loan, and a down payment is a Reg Z trigger term for closed-end purchase loans (12 CFR 1026.24(d)).
- **Button wording**: "Check Your Numbers / Get Pre-Qualified" in the advisor card (Pat's wording). The calculator and its "Lock In These Numbers" button were removed on 2026-11-21 (D90).
- **Advisor claims**: "Big-box banks size your line on today's equity... so many ADU plans get turned down", "Pat specializes in ADU financing". Since D91 Pat is named only in the advisor card (with photo, NMLS and company) and the footer; the rest of the page says "your ADU loan advisor".
- **Illustrations**: the hero, project tiles and example properties are AI-generated 3D renders (Higgsfield), not photos of real projects.
- **FAQ "draw inspections"**: now says no bank draw schedule, no HUD consultant, cash-buyer speed for the contractor, streamlined oversight after closing, one final 1004D completion inspection. The post-closing supervision fee ($149 a month in the deck) is no longer mentioned there; the answer says Pat reviews all rates, terms and costs up front. Make sure that fee is disclosed in the first conversation.

### Contact details now on the page
Phone (949) 787-2662 (header, hero, advisor card, final section, footer and the phone bottom bar) and pcollins@emortgagecapital.com (the "send your plans or bid" link; the address is only in the link, not shown as text) come from the confirmed identity list above. The advisor card shows Pat's headshot (D91).

## Where each placeholder appears
Generated by `scripts/pat-scan.ps1` (run `powershell -File scripts\pat-scan.ps1`).

<!-- PAT-SCAN:START -->
Total placeholders in source: **69** across 18 files (a placeholder in a shared footer or template shows on every page that uses it).

| Count | File |
|---|---|
| 1 | ads/ad-copy.md |
| 4 | ads/chatgpt-ads-prep.md |
| 4 | scripts/build.ps1 |
| 3 | src/data/identity.json |
| 5 | src/funnel/faq.json |
| 16 | src/funnel/index.html |
| 13 | src/hub/pages/200k-adu-example.html |
| 3 | src/hub/pages/about-pat.html |
| 4 | src/hub/pages/construction-or-renovation-loan.html |
| 1 | src/hub/pages/costs-to-expect.html |
| 1 | src/hub/pages/heloc-for-adu.html |
| 1 | src/hub/pages/heloc-vs-cash-out-refinance.html |
| 2 | src/hub/pages/keep-low-first-mortgage-rate.html |
| 4 | src/hub/pages/pasadena.html |
| 1 | src/hub/pages/pillar.html |
| 1 | src/hub/pages/questions-to-ask-lender.html |
| 2 | src/hub/pages/rental-income-qualifying.html |
| 3 | src/hub/pages/reverse-mortgage-for-adu.html |

| File | Line | Placeholder |
|---|---|---|
| ads/ad-copy.md | 37 | [PAT: headshot] |
| ads/chatgpt-ads-prep.md | 11 | [PAT: company license numbers and proof] |
| ads/chatgpt-ads-prep.md | 15 | [PAT: confirm "FinanceMyADU" is an approved trade name for E Mortgage Capital and that compliance approves its use] |
| ads/chatgpt-ads-prep.md | 32 | [PAT: create an ADU qualifier form, or tell me to use another endpoint] |
| ads/chatgpt-ads-prep.md | 34 | [PAT: confirm you control financemyadu.io] |
| scripts/build.ps1 | 125 | [PAT: confirm "FinanceMyADU" is an approved trade name for E Mortgage Capital and that compliance approves its use] |
| scripts/build.ps1 | 193 | [PAT: confirm application link for this campaign] |
| scripts/build.ps1 | 330 | [PAT: real scenario from my files; numbers as ranges; what went wrong or surprised me; what I would tell a homeowner in this exact situation] |
| scripts/build.ps1 | 501 | [PAT: ...] |
| src/data/identity.json | 59 | [PAT: confirm application link for this campaign] |
| src/data/identity.json | 67 | [PAT: other real profile URLs for sameAs (YouTube, newsletter, LinkedIn, Google Business Profile)] |
| src/data/identity.json | 149 | [PAT: compliance to approve final consent wording] |
| src/funnel/faq.json | 9 | [PAT: which of your programs can combine an ADU with other renovation work, and what they need] |
| src/funnel/faq.json | 14 | [PAT: confirm which of your programs consider ADU rental income or after-ADU value] |
| src/funnel/faq.json | 19 | [PAT: typical timelines for the ADU financing options you offer] |
| src/funnel/faq.json | 24 | [PAT: confirm what you can say about the cost of a first conversation and no-obligation wording] |
| src/funnel/faq.json | 29 | [PAT: confirm whether your financing works with any licensed builder and what builder or plan information lenders need] |
| src/funnel/index.html | 42 | [PAT: confirm no-obligation wording] |
| src/funnel/index.html | 55 | [PAT: compliance to approve final consent wording] |
| src/funnel/index.html | 55 | [PAT: confirm no-obligation and no-credit-check wording] |
| src/funnel/index.html | 113 | [PAT: which renovation and construction programs you offer] |
| src/funnel/index.html | 124 | [PAT: verify HECM rules for funding an ADU] |
| src/funnel/index.html | 190 | [PAT: which renovation programs you offer, so this column can be filled in] |
| src/funnel/index.html | 221 | [PAT: confirm the lender of record for reverse mortgages and the disclosures required when it is named] |
| src/funnel/index.html | 221 | [PAT: verify HECM rules for funding an ADU] |
| src/funnel/index.html | 233 | [PAT: project cost] |
| src/funnel/index.html | 234 | [PAT: loan type] |
| src/funnel/index.html | 235 | [PAT: rate and APR] |
| src/funnel/index.html | 236 | [PAT: term] |
| src/funnel/index.html | 237 | [PAT: payment] |
| src/funnel/index.html | 238 | [PAT: assumptions and Regulation Z disclosures approved by lender] |
| src/funnel/index.html | 249 | [PAT: real story and written permission] |
| src/funnel/index.html | 250 | [PAT: second real story and written permission, optional] |
| src/hub/pages/200k-adu-example.html | 27 | [PAT: how you describe the equity step, with the balance as a range] |
| src/hub/pages/200k-adu-example.html | 39 | [PAT: answer in words] |
| src/hub/pages/200k-adu-example.html | 39 | [PAT: answer in words] |
| src/hub/pages/200k-adu-example.html | 39 | [PAT: answer in words] |
| src/hub/pages/200k-adu-example.html | 40 | [PAT: balance range Pat supplies, with assumptions stated] |
| src/hub/pages/200k-adu-example.html | 41 | [PAT: lender's approach, in words] |
| src/hub/pages/200k-adu-example.html | 41 | [PAT: lender's approach, in words] |
| src/hub/pages/200k-adu-example.html | 41 | [PAT: lender's approach, in words] |
| src/hub/pages/200k-adu-example.html | 42 | [PAT: cost categories, no figures] |
| src/hub/pages/200k-adu-example.html | 42 | [PAT: cost categories, no figures] |
| src/hub/pages/200k-adu-example.html | 42 | [PAT: cost categories, no figures] |
| src/hub/pages/200k-adu-example.html | 43 | [PAT: include only if a lender approves the required disclosures; otherwise leave this row out] |
| src/hub/pages/200k-adu-example.html | 67 | [PAT: a real project of about this size from my files, with numbers as ranges, what the homeowner chose and why, and what went wrong or surprised me; permission needed] |
| src/hub/pages/about-pat.html | 21 | [PAT: confirm the exact wording of Pat's years of experience, and add real estate license, reverse mortgage designations or other credentials only if they are verifiable] |
| src/hub/pages/about-pat.html | 22 | [PAT: fuller bio in your own words and a headshot with alt text] |
| src/hub/pages/about-pat.html | 57 | [PAT: real ADU financing experience in your own words: kinds of projects, anything you learned, and what homeowners most often get wrong; no client names without written permission] |
| src/hub/pages/construction-or-renovation-loan.html | 10 | [PAT: verify any FHA or other renovation program you want described here] |
| src/hub/pages/construction-or-renovation-loan.html | 15 | [PAT: which renovation and construction programs you offer, and what you can say about each] |
| src/hub/pages/construction-or-renovation-loan.html | 26 | [PAT: which of the programs you offer can combine an ADU with other renovation work, and what they need] |
| src/hub/pages/construction-or-renovation-loan.html | 29 | [PAT: how draws and inspections work for the programs you offer] |
| src/hub/pages/costs-to-expect.html | 32 | [PAT: whether to mention insurance as a cost category and how] |
| src/hub/pages/heloc-for-adu.html | 29 | [PAT: how you explain limits for ADU projects, in plain words with no numbers] |
| src/hub/pages/heloc-vs-cash-out-refinance.html | 39 | [PAT: how you walk clients through the comparison for an ADU project] |
| src/hub/pages/keep-low-first-mortgage-rate.html | 21 | [PAT: how the renovation programs you offer treat the existing mortgage] |
| src/hub/pages/keep-low-first-mortgage-rate.html | 31 | [PAT: whether to suggest clients bring their latest mortgage statement to the first call] |
| src/hub/pages/pasadena.html | 10 | [PAT: verified California ADU law facts from HCD or the Legislature; automated reads of hcd.ca.gov were blocked during the build] |
| src/hub/pages/pasadena.html | 32 | [PAT: verified California ADU law facts from HCD or the Legislature, with citations; automated reads of hcd.ca.gov were blocked during the build, so none are stated here] |
| src/hub/pages/pasadena.html | 33 | [PAT: verify with the City whether any city-run ADU financing or assistance program is currently open, and describe it only from the city's own page] |
| src/hub/pages/pasadena.html | 54 | [PAT: how your process works for Pasadena projects] |
| src/hub/pages/pillar.html | 32 | [PAT: which renovation and construction programs you offer] |
| src/hub/pages/questions-to-ask-lender.html | 45 | [PAT: your typical timeline wording for ADU financing] |
| src/hub/pages/rental-income-qualifying.html | 29 | [PAT: confirm which programs you offer that consider ADU rental income or after-ADU value, and in what situations] |
| src/hub/pages/rental-income-qualifying.html | 32 | [PAT: confirm whether any of your programs fits an owner-occupied home with an ADU] |
| src/hub/pages/reverse-mortgage-for-adu.html | 10 | [PAT: verify HECM rules for funding an ADU with an official HUD source] |
| src/hub/pages/reverse-mortgage-for-adu.html | 19 | [PAT: confirm the lender of record for reverse mortgages and the disclosures required when it is named] |
| src/hub/pages/reverse-mortgage-for-adu.html | 33 | [PAT: verify HECM rules for funding an ADU, including who may live in the ADU and whether renting it affects the loan] |
<!-- PAT-SCAN:END -->
