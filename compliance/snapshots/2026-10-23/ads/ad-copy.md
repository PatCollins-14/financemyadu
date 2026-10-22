# ChatGPT ad copy variants (draft, needs compliance approval)

Source of truth: `ads/ad-copy.csv`. Character counts come from `run.cmd adcheck` (output in `ads/ad-copy-counts.md`).

**UNVERIFIED:** the reported ad-format limits (titles about 16 to 24 characters, descriptions about 32 to 48) come from the build brief. Check them in OpenAI's ad manager before use.

The ads sell the financing, never a specific rental unit or property sale. No rates, payments, "fastest", "guaranteed" or "preapproved".

## Titles
| ID | Text | Characters |
|---|---|---|
| T1 | ADU Financing Options | 21 |
| T2 | Pay for Your ADU | 16 |
| T3 | Compare ADU Loans | 17 |
| T4 | Fund Your Backyard ADU | 22 |
| T5 | Smart ADU Financing | 19 |
| T6 | Your ADU, Your Options | 22 |

## Descriptions
| ID | Text | Characters |
|---|---|---|
| D1 | Compare ways to pay for your ADU in California. | 47 |
| D2 | Talk with a CA mortgage pro about ADU loans. | 44 |
| D3 | See which option fits your home and your goal. | 46 |
| D4 | Home equity, refinance and more, explained. | 43 |
| D5 | Clear options, honest guidance on ADU loans. | 44 |
| D6 | Pat Collins, NMLS #1628553. Compare ADU options. | 48 |

All 12 are inside the reported ranges and pass the banned-phrase check (re-run `run.cmd adcheck` after any edit).

## Square-image concept notes
1. **Backyard unit, daytime.** A small modern backyard unit beside a main house. No people, no price tags, no "rent" or "income" text. Caption area empty.
2. **Floor-plan sketch.** A simple line drawing of a lot with a main house and an ADU. Feels like planning, not a sale.
3. **Two doors, one decision.** Two simple illustrated paths labeled "Home equity" and "Refinance". No numbers.
4. **Pat Collins, headshot plus NMLS line.** Only after Pat supplies a headshot and compliance approves the NMLS line. `[PAT: headshot]`
Do not show a specific property for sale or rent. Do not show currency, percentages or logos of other companies.

## Pairing
Send each ad to the funnel with `utm_content` set to the variant, for example `utm_content=T1-D1`. See `docs/MEASUREMENT.md`.
