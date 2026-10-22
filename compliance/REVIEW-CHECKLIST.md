# Compliance review checklist (E Mortgage Capital)

For Pat's compliance contact at E Mortgage Capital. Nothing ships until its row says **APPROVED** with a date (YYYY-MM-DD). The production build (`run.cmd production`) and the preflight gate read the Status and Approval date columns of this table. Allowed statuses: `pending`, `APPROVED`, `changes-needed`.

How to review: open the dated snapshot in `compliance/snapshots/<date>/` (made with `run.cmd snapshot`) so you see exactly what was reviewed. Every page lists its sources at the bottom or in `docs/SOURCE-MAP.md`.

| ID | Page or asset | Status | Approval date | Reviewer | Changes requested |
|---|---|---|---|---|---|
| `funnel` | Funnel page, MyADUFinancing.com (noindex) | pending | | | |
| `pillar` | Hub: How to finance an ADU in California | pending | | | |
| `heloc-for-adu` | Hub: Can I use a HELOC to build an ADU? | pending | | | |
| `heloc-vs-cash-out-refinance` | Hub: HELOC vs cash-out refinance for an ADU | pending | | | |
| `construction-or-renovation-loan` | Hub: Construction and renovation loans for an ADU (educational) | pending | | | |
| `rental-income-qualifying` | Hub: Can ADU rental income count toward qualifying? | pending | | | |
| `reverse-mortgage-for-adu` | Hub: Can a reverse mortgage fund an ADU? (COMPLIANCE-GATE, noindex until approved) | pending | | | |
| `keep-low-first-mortgage-rate` | Hub: Will financing an ADU affect my current mortgage rate? | pending | | | |
| `200k-adu-example` | Hub: $200,000 ADU on a $1.2 million home (framework) | pending | | | |
| `pasadena` | Hub: ADU financing in Pasadena | pending | | | |
| `questions-to-ask-lender` | Hub: Questions to ask your lender | pending | | | |
| `costs-to-expect` | Hub: Costs to expect | pending | | | |
| `faq` | Hub: Consolidated FAQ | pending | | | |
| `about-pat` | Hub: Pat Collins author page | pending | | | |
| `ads-chatgpt` | ChatGPT ad copy variants (`ads/ad-copy.md`) | pending | | | |

## High-risk items to review closely
| Item | Where | Why it needs a look |
|---|---|---|
| Reverse mortgage content and the lender of record | `reverse-mortgage-for-adu`, funnel senior section and card (hidden by `SHOW_REVERSE_SECTION=false`) | CFPB has penalized misleading reverse mortgage advertising; site names Finance of America Reverse LLC, footer names only E Mortgage Capital |
| Worked example | funnel (hidden by `SHOW_EXAMPLE=false`) and `200k-adu-example` | Any rate, payment, APR or term triggers Regulation Z disclosures; the 30% cap and two scenario figures are the only numbers allowed anywhere |
| BBB reviews | funnel local-proof section | Reviews are about E Mortgage Capital, not ADU loans or Pat personally. One summary mentions a timeline ("under a month"), shown verbatim from the home page |
| Form consent and text-message wording | funnel quiz | Wording copied from the live site; needs approved final text |
| "MyADUFinancing" trade name | funnel footer | Needs approval as a trade name for E Mortgage Capital |
| "30+ years" and "Licensed in California" | funnel trust strip | Pat's own statements, not on the website |
| DRE number and label | every footer and byline | Footers now show "DRE #02143449" (confirmed by Pat in chat); the live website says "BRE". Confirm the label |
| Rental income statements | funnel, `rental-income-qualifying` | Cites Fannie Mae Selling Guide B3-3.8-02 (version dated 09/02/2026); confirm wording and currency |
| Statements about Pasadena | `pasadena` | Sourced from the City's ADU page read on 2026-10-23 |
| "No obligation" and "no credit check" | funnel hero and form | Shown only as `[PAT: confirm ...]` placeholders until confirmed |
