# Site issues found on letstalkhomemortgage.com (read-only report)

Retrieved 2026-10-23. Nothing here was fixed or changed. The live site was only read.
Items 1-9 are the ones already in the build brief (Appendix H). Items 10-18 are new findings from this crawl.

## Already known (brief, Appendix H)

1. **Footer license label.** Footer reads "BRE #02143449". The BRE became the DRE; label needs a compliance check.
2. **Reverse mortgage "Requirements" table has VA text.** The "Loan Types" and "Funding Fee" rows describe VA loans. Confirmed on /reverse-mortgage/.
3. **Out-of-date loan limit.** /refinance/ conforming and conventional tables cite a 2022 limit of $647,200 as current.
4. **Entity mismatch.** /reverse-mortgage/ sends readers to Finance of America Reverse LLC (FAR); the footer names only E Mortgage Capital. Confirm licensed entity and disclosures.
5. **Navigation.** Older WordPress menu still lists "Credit Repair"; the old header logo loads from `http://patrickc66.sg-host.com/wp-content/uploads/2022/01/Patrick-Logo.png` (staging host, plain http).
6. **Meta descriptions.** /contact-us/ and /articles/ each output two meta description tags (one from the old template, one from Yoast). /contact/ (an older page) uses different wording ("Let's Talk Homeownership").
7. **Rate-and-savings language.** /todays-rates/ and /refinance/ ("Lower your rate and monthly payment right NOW!", "could save you thousands of dollars per year") likely trigger Regulation Z advertising rules.
8. **Reviews are E Mortgage Capital's.** Home page reviews come from E Mortgage Capital's BBB profile, not Pat personally.
9. **Calls to action.** "FREE quote" and "Get preapproved" CTAs on reverse mortgage and HELOC pages need compliance review.

## New findings

10. **Spam posts in the post sitemap (security).** `post-sitemap.xml` lists four posts dated March 2026 with unrelated or harmful topics: `/kmspico-for-office-2016/` (software activator), `/pliusy-i-minusy-stavok-na-sport-cherez-vavada/` (gambling), `/mostbet-velemenyek/` (gambling), `/telegram-desi-porn/` (adult). They look like an injection or hacked-account posts. Treat as a possible compromise: check WordPress users, plugins and recent logins, remove the posts, and request re-crawl. These pages sit on the same domain the hub is meant to join, so clean this up before launching the hub there.
11. **Dozens of stale, test and duplicate pages are in the page sitemap.** Examples: `/test-form/`, `/test-ff/`, `/funnel-duplicate-3373/`, `/todays-rate-duplicate-521/`, `/purchase-thank-you-2/` to `-5/`, `/reverse-mortgage-copy/`, `/rreverse/`, `/rem/`, `/contact-us-old/`, `/shop/`, `/cart/`, `/checkout/`, `/my-account/`. Thin or duplicate pages dilute site quality signals. Noindex or remove them.
12. **Broken footer link.** `/dti-calculator/` returns 404, while the Tools page presents the DTI calculator. Footer also links `/privacy/` and `/terms/`, but the sitemap lists `/privacy-policy/` and `/terms-and-conditions/` (both pairs return 200; two versions of each policy may exist).
13. **Legacy "Top 20" FAQ pages use a default WordPress theme.** `/top-20-*-questions-and-answers/` pages show "Twenty Twenty-Five / Designed with WordPress" chrome and "Click here to see if you qualify." One page (reverse mortgage Q20) contains leftover drafting text: 'Your "Learn More" button can link to a dedicated page...'. Replace or noindex.
14. **Unsupported claims in legacy FAQs.** "We have over 80 different lenders to compete for your loan" and "typically takes from 2 to 4 weeks from application to funding" and "30-45 days from application to closing" appear without support. Not copied.
15. **/reviews/ shows testimonials with no source.** Four first-name-only quotes (Karen; Amanda and Jim; Mina; Samir) with "Rated 5 out of 5" and no platform, date or permission note. These differ from the BBB review block on the home page. Not used. Compliance should confirm they are real and permissioned.
16. **Reverse mortgage page contradicts itself on obligations.** The headline pros say "No Monthly Payments" and "never owe more than the home is worth"; the FAQ section says taxes, insurance, HOA fees and upkeep must be paid or the loan can become due, and foreclosure is possible. Advertising claims should include the obligations next to the benefit.
17. **Two Facebook pixel IDs** (`744973237149490`, `748715263858677`) load through PixelYourSite and Complianz placeholders. Confirm both are intentional and that marketing consent is respected before any new ad traffic is sent through GTM.
18. **Articles page vs sitemap.** Articles page lists 18 current articles; the sitemap has older 2023-2025 posts (rates, housing market) that are not in the listing. Consider refreshing or consolidating old rate commentary, which can read as dated rate advice.
19. **Renovation financing is not on the site.** Pat confirmed (chat 2026-10-23) that he offers renovation financing, but none of the product pages (`/purchase/`, `/refinance/`, `/heloc-loans/`, `/reverse-mortgage/`, `/non-qm-mortgage/`) mention renovation or construction loans. The ADU funnel and hub now say Pat helps with renovation financing, so the main site should say so too, or the two will not match.
