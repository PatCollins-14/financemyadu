# Build brief

## Goal
Booked consultations from California homeowners who want to finance an ADU, from two sources: (1) paid traffic from ChatGPT ads to a focused funnel page; (2) organic and AI-answer discovery through an expert education hub. SEO, GEO, AEO and LLMO are treated as one discipline: crawlable, fast, expert, first-hand, trustworthy pages. No tricks.

## Three assets
| Asset | Purpose | Domain | Indexing |
|---|---|---|---|
| A. Funnel | Convert paid traffic into booked consultations. One offer, no site menu. | FinanceMyADU.io (parked today with a blocking robots.txt; domain control to be confirmed by Pat) | `noindex` through meta tag, flag `FUNNEL_NOINDEX=true`. robots.txt allows everything. |
| B. Education hub | SEO / GEO / AEO. Pat's name, licenses and expertise (E-E-A-T). | `/adu-financing/` on LetsTalkHomeMortgage.com (subfolder or subdomain via `HUB_BASE_URL`) | Indexable; COMPLIANCE-GATE pages noindex until approved. |
| C. LetsTalkADU.com | ADU design, construction, permitting | not built | Later |

### Later (Asset C)
LetsTalkADU.com is **not built now**. Pat has not confirmed what is on the domain. It needs a named builder or architect as co-author, because ADU design and permitting are outside a mortgage professional's expertise. No content in this build claims construction or permitting expertise for Pat.

## Page list
Funnel (`/`): hero, trust strip, option comparison, ADU angle, senior path (gated), worked example (hidden), 3-step process, local proof, FAQ, repeat CTA, disclosure footer. Lead form in the form band: full name, email, phone and an optional upload of existing plans (Pat, 2026-10-23; replaces the earlier multi-step quiz). Visual design follows Pat's template `adu-financing.html`.

Hub (13): pillar; HELOC for ADU; HELOC vs cash-out refinance; construction or renovation loan (educational); ADU rental income and qualifying; reverse mortgage for ADU (gated); keep your low first-mortgage rate; $200,000 ADU on a $1.2 million home (framework); Pasadena; questions to ask your lender; costs to expect; Pat Collins author page; consolidated FAQ.

## Hub page template
H1 as the question, 1-3 sentence direct answer, byline with NMLS, visible "Last reviewed" date matching `dateModified`, sections (Who this fits / Who it does not fit / Trade-offs / What to ask a lender / What I see in real ADU financing (placeholder) / Related questions / Sources), one CTA block, disclosure footer, draft banner until approved.

## Delivery
Native static output in `dist/hub/` plus `hub/wordpress-ready/<slug>.html` and `.meta.json` for pasting into WordPress and Yoast.
