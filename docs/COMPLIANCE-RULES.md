# Compliance rules (build brief section 9, with Appendix B and G)

All pages are mortgage advertising or educational content for a licensed California mortgage professional. These rules are enforced in code by `scripts/preflight.ps1`. This file is guidance for people; it is not legal advice. Pat's compliance contact at E Mortgage Capital has the final say.

## Rules
1. **Identifiers on every page** (shared footer): Pat Collins, individual NMLS, DRE number (after Pat confirms), E Mortgage Capital Inc. and its NMLS, address, NMLS Consumer Access link, Equal Housing Opportunity logo and words.
2. **Standard disclosure** (text from Pat's live site, pending compliance review): "This is not a commitment to lend. All loans are subject to credit, income, property, and underwriting approval. Programs, rates, and terms may change without notice." ADU pages add: "Rental income is not guaranteed and may not be counted for qualification under every program."
3. **No rates, payments, APRs, loan amounts, down payments, terms, repayment periods** on any page by default. These are Regulation Z "trigger terms" that bring extra disclosures. Use "see your options" language. Exceptions are per page (`allowTerms` in a page's front matter) and need compliance sign-off.
4. **Banned claims**: see list below and `config/banned-phrases.json`. Preflight fails the build if any appear.
5. **Reverse mortgage wording**: always state that borrowers must keep paying property taxes, insurance, HOA fees and upkeep, and that failing to do so can make the loan due. Never "no payments", "can't lose your home", "eliminate debt", or "never owe more than the home is worth".
6. **No state endorsement**: never imply the State of California, DFPI or DRE approves or endorses rates or services.
7. **No "you're preapproved"** and no specific amount offers. Prefer "Start your application" or "See my financing options". "Pre-approval" only as a neutral process term compliance approves.
8. **Prohibited adjacent topics** (also an OpenAI ad-policy risk): no debt consolidation, debt settlement, debt assistance or credit repair anywhere.
9. **Housing rule for ads**: sell the financing, never a specific rental unit or property sale.
10. **Records**: `run.cmd snapshot` saves a dated copy of every page version and ad in `compliance/snapshots/<date>/`.
11. **Sign-off gate**: no page ships until `compliance/REVIEW-CHECKLIST.md` marks it APPROVED. The production build refuses unapproved pages.

## Banned list (Appendix B), summarized
guaranteed or guarantee, "you're approved/preapproved", no credit check (unless approved), lowest or best rate, rates as low as, our rates are low, fixed rate of, APR (any use), any percentage, "per month" or "/mo", monthly payment of, any dollar amount, zero down or no money down, no payments or no monthly payments, payment-free, can't or never lose your home, never owe more than, eliminate or wipe out debt, free money, free quote, fastest, instant approval, state/DFPI/DRE approved, debt consolidation / relief / settlement / assistance, credit repair, fix your credit, risk-free or no risk, act now, limited time, rental income guaranteed, pays for itself, save thousands, could save you, lower your rate and monthly payment, "get preapproved/pre-approved", "no obligation" (needs Pat's confirmation).

## Appendix G: claims on the live site that are NOT copied
- Reverse mortgage page: "No Monthly Payments", "FREE quote", "Our Reverse Mortgage Rates Are Low", the non-recourse "never owe more than the home is worth" line.
- Refinance page: "Lower your rate and monthly payment right NOW!", "could save you thousands of dollars per year", "best rate".
- Non-QM page: "save thousands of dollars per year" and all program parameters.
- HELOC and refinance pages: debt consolidation language; the 80%-85% LTV, "2% to 5%" closing cost, "as little as two weeks", credit-score and DTI minimums, 2022 conforming limit.
- "Get Preapproved" / "pre-approved" as promotional labels; the "Credit Repair" nav link; any claim that rates are "low" or "the best".

## Additions found during this build
- Legacy FAQ claims "over 80 different lenders" and "2 to 4 weeks" / "30-45 days" timelines: not copied (unsupported).
- Percent and dollar figures: blocked everywhere by default. Two documented exceptions, both needing compliance sign-off: (a) the hub page on ADU rental income quotes Fannie Mae's published "30%" cap with the source cited; (b) the worked-scenario page states its example project cost and home value as scenario assumptions, not as an offer.
- "no obligation": allowed only as a `[PAT: confirm ...]` placeholder until Pat and compliance confirm it.
- Facebook pixel / marketing tags must not fire before consent (see MEASUREMENT.md).
