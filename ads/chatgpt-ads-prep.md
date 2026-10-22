# ChatGPT ads preparation

Files only. Nothing here submits anything to OpenAI.

## 1. Approval prep: have these ready
Financial services is a restricted ad category, and mortgages are reviewed case by case.

| Item | Status |
|---|---|
| Pat's NMLS record (NMLS #1628553) and a link to NMLS Consumer Access | have: public |
| E Mortgage Capital Inc. company license (NMLS #1416824) and the state licenses it relies on | `[PAT: company license numbers and proof]` |
| DRE license number: #02143449 (confirmed by Pat in chat 2026-10-23; the website label says "BRE") | have; compliance to confirm the label |
| The landing page, live and approved by compliance | built in `dist/funnel/`; needs approval and deployment |
| **One legal entity everywhere.** The ad account, the landing page and the NMLS company must all say E Mortgage Capital Inc., NMLS #1416824, with Pat as the loan officer | footer and trust strip already say this |
| "FinanceMyADU" trade-name approval | `[PAT: confirm "FinanceMyADU" is an approved trade name for E Mortgage Capital and that compliance approves its use]` |
| Compliance pre-approval of every ad and the page (E Mortgage Capital may require it) | see `compliance/REVIEW-CHECKLIST.md` row `ads-chatgpt` |

Targeting: United States only.
Prohibited ad topics: credit repair, debt settlement and debt assistance ads are prohibited. Ads must not exaggerate results. The ad copy and the funnel page contain none of these.

## 2. Ad copy
See `ads/ad-copy.md` and `ads/ad-copy.csv`. Six titles and six descriptions, character counts checked by script.
**UNVERIFIED:** reported format limits (titles about 16 to 24 characters, descriptions about 32 to 48). Confirm in OpenAI's ad manager.

## 3. Landing-page requirements checklist
- [ ] Loads fast on mobile (measure after deployment; not measured in this build).
- [ ] It is an offer page, not the homepage of a company site (done: one offer, no site menu).
- [ ] Does not block `OAI-AdsBot`, `OAI-SearchBot` or Googlebot (done: robots.txt has explicit allow groups, no `Disallow: /`). The page is hidden from search with a meta `noindex`, not with robots.txt.
- [ ] The page matches the ad's promise: financing options for an ADU, nothing more.
- [ ] No rates, payments, APRs, loan amounts, "preapproved", "guaranteed" or other banned phrases (enforced by `run.cmd preflight`).
- [ ] Licensee identity is clear: Pat Collins, E Mortgage Capital Inc., both NMLS numbers, Equal Housing Opportunity.
- [ ] The form posts to a real endpoint (`FORM_ENDPOINT`) and has a consent checkbox. `[PAT: create an ADU qualifier form, or tell me to use another endpoint]`
- [ ] Consent and cookie handling: analytics stay off until a visitor accepts (`ANALYTICS_ID` is `GTM-TQ8C7WLM`; nothing loads before the visitor presses Accept).
- [ ] The domain FinanceMyADU.io points at the deployed funnel (DNS is Pat's task; not done here). On 2026-10-23 financemyadu.io answered HTTP 200 with a parked robots.txt of `User-agent: * / Disallow: /`, which would block crawlers including OAI-AdsBot. This build's robots.txt must replace it before ads run. `[PAT: confirm you control financemyadu.io]`

## 4. Campaign tags
`utm_source=chatgpt`, `utm_medium=cpc`, `utm_campaign=adu-financing`, `utm_content=<ad variant>`. Details in `docs/MEASUREMENT.md`.
