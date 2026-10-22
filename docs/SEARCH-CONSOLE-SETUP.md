# Search tools setup (steps for Pat)

I cannot do these; they need your accounts.

## Google Search Console
1. Add the property where the hub will live: a URL-prefix property for `https://letstalkhomemortgage.com/adu-financing/` if the hub is a subfolder, or a Domain property if it is a subdomain. Verify with a DNS record or the HTML tag method.
2. Submit `sitemap.xml` (built in `dist/hub/sitemap.xml`). If the hub is inside the WordPress site, also add its URLs to the Yoast sitemap or submit this file as an extra sitemap.
3. Inspect each hub URL once after launch (URL Inspection > Request indexing) to confirm Google can fetch and render it.
4. Use the performance report for hub pages. Google has added a generative AI performance report to Search Console; if it is available for your property, check it monthly. `[PAT: confirm the report is available in your account]`
5. Run Google's Rich Results Test on each hub URL (the JSON-LD parses locally, but I could not run Google's tool).

## Bing Webmaster Tools
Add the same site and submit the same sitemap. **Unverified:** whether Bing indexing affects ChatGPT visibility. Do it for Bing's own search traffic, not for ChatGPT.

## ChatGPT search
OpenAI documents `OAI-SearchBot` as the crawler that surfaces sites in ChatGPT search results. The hub's robots.txt allows it explicitly. `GPTBot` (training) is a separate choice; default is allow (`ALLOW_GPTBOT=true`), which does not affect search inclusion. `[PAT: decide whether to allow GPTBot]`

## Ads
`OAI-AdsBot` must be able to fetch the funnel page. Its robots.txt allows it explicitly. The funnel is hidden from search with a meta `noindex` tag, not a robots.txt block.
