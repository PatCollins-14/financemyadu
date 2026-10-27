# Go-live: financemyadu.io on GitHub Pages

**Status (2026-10-28):** LIVE. The DRAFT site is served at https://financemyadu.io/ from https://github.com/PatCollins-14/financemyadu (public). DNS: one A record (185.199.108.153) on the root and a `www` CNAME to `patcollins-14.github.io`. The HTTPS certificate is approved (covers the root and www, expires 2027-01-26 and renews on its own) and Enforce HTTPS is on: http and www redirect to https://financemyadu.io/.

## 1. DNS (done). Reference: the records you need

Open the DNS settings for `financemyadu.io` and make these records. Delete the old records first: the apex `A` record `2.57.91.91` and the `www` record that aliases it.

| Type | Name / Host | Value |
|---|---|---|
| A | @ (root) | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |
| AAAA (optional) | @ | 2606:50c0:8000::153 |
| AAAA (optional) | @ | 2606:50c0:8001::153 |
| AAAA (optional) | @ | 2606:50c0:8002::153 |
| AAAA (optional) | @ | 2606:50c0:8003::153 |
| CNAME | www | patcollins-14.github.io |

DNS can take from a few minutes to a day. Check with `nslookup financemyadu.io`: it should list the 185.199.x.153 addresses.

## 2. HTTPS (done)

GitHub issues the certificate on its own once DNS points at it (often within an hour). Then in the repo: Settings, Pages, tick **Enforce HTTPS**. Ask Claude to do it with the API once the certificate is ready.

## 3. What visitors see now (draft)

- `financemyadu.io/` redirects to `financemyadu.io/funnel/`.
- The yellow `[PAT: ...]` notes and the DRAFT banners on guide pages are visible.
- The form is not connected: it tells people it did not send. Do not run ads to it yet.
- Every page has a meta noindex tag, so search engines should not list it. No analytics or cookies load.
- The guide pages live under `/hub/` (also noindex).

## 4. Replace the draft with the real site

1. Get E Mortgage Capital compliance approval and mark each page APPROVED, with a date, in `compliance/REVIEW-CHECKLIST.md`.
2. Fill in the yellow notes (the questions form) and connect the lead form (`FORM_ENDPOINT`).
3. In `.github/workflows/pages.yml`, replace the build step with `scripts/build.ps1 -Production` followed by `scripts/preflight.ps1`, and drop the draft layout in `scripts/pages-build.ps1`.
4. Commit and push to `main`. The workflow redeploys.

## 5. Everyday use

- Any push to `main` redeploys within about a minute. You can also run the workflow by hand from the Actions tab.
- To take the site down: Settings, Pages, Unpublish site (or delete the DNS records).
