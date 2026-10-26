# Reviews section: copy-and-paste guide

Files in this folder:

| File | What it is |
|---|---|
| `reviews-section.html` | The whole section: styles, markup and script in one block. This is the file you copy. |
| `demo.html` | The same block on a plain page, so you can open it in a browser and see it working. |
| `GUIDE.md` | This guide. |

## 1. Put it on a page

1. Open `reviews-section.html`, select everything from the first `<!--` comment to the last `</script>`, and copy it.
2. Paste it where the section should go:
   - **WordPress block editor:** add a **Custom HTML** block and paste. Do not use a Paragraph or Classic block; they add stray paragraph tags that break the data.
   - **Elementor:** drag an **HTML** widget onto the page and paste.
   - **Other builders (Webflow, Squarespace, Wix, GoHighLevel):** use the "Embed" or "Custom code" element. If it only accepts an iframe, host the file and point the iframe at it.
   - **Plain HTML site:** paste it into the page where the section should appear.
3. Publish and check the page on desktop and on a phone.

The section has no dependencies and no build step. It uses your site's font (it inherits `font-family`). To use Hanken Grotesk like the funnel, add this once to the page head:
`<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Hanken+Grotesk:wght@300;400;500;600;700&display=swap">`

## 2. Change the content: only the JSON

Everything you see comes from the block marked `EDIT THIS JSON ONLY`. Keep the quotes, commas and brackets exactly as they are; change only the text inside the quotes.

**Top level**

| Field | What it does |
|---|---|
| `kicker`, `title` | Small gold label and the big heading. Wrap the blue italic words in `<em>...</em>`. |
| `intro`, `introSub` | The line above the profile tiles and the sentence under it. |
| `note` | The small print under the carousel. Keep it honest: say they are selected reviews and that the ratings cover every review. Empty it (`""`) to hide it. |
| `hideNames` | Names that are always hidden wherever they appear in a review (see section 4). |

**`platforms`** (the four tiles): one entry per site.
`id` (a short word you reuse in the reviews), `name`, `rating` (a number, for example `4.7`; leave `""` to show "Customer reviews" instead), `count`, `unit` (the word after the count), `url` (the profile page), `logo` (a full image address, or `""` for a text name), `logoScale` (1 is normal; raise it if a logo looks small next to the others).

**`reviews`** (the cards): one entry per review.
`p` (the platform `id`), `name` (as the site shows it, for example `Dennis S.`), `date`, `stars` (1 to 5), `text`, and `verbatim` (`true` puts quotation marks around the text; use it only when the text is the reviewer's exact words).

Add a card by copying one whole `{ ... },` line. Remove a card by deleting its line. The last item in a list has no trailing comma.

**`embeds`**: platform widgets (section 5). Leave `[]` if you have none.

## 3. Logos

Upload each logo to your site's media library and paste its address into `logo`. Use the same crop for all of them (a wide image of just the logo, with no review count baked in, because counts go stale). The section puts every logo in the same box, so they come out matching. If one looks smaller, raise its `logoScale`.

## 4. Exact review text, and hiding staff names

Only use review text you have the right to show: copied by the business owner from its own review accounts, or supplied by a review tool you are authorised to use. Keep the reviewer's wording exactly. The section never edits it.

To hide a staff name inside a review:

- **Best:** write `[[8]]` where the name was. The number is how many letters to hide. The page then shows blurred filler and the real name is nowhere in the page code.
- `[[Name]]` also hides the name on screen, but the name is still in the page code, so anyone who views the source can read it.
- Names in `hideNames` are hidden automatically, with the same on-screen result and the same caveat.

Screen readers hear "[name hidden]" for each one.

## 5. Platform widgets (optional)

If a platform gives you its own embed code, add it to `embeds`:

```json
"embeds": [ { "name": "Yelp", "html": "<paste the platform's embed code here as one line, with every double quote written as \\\">" } ]
```

The widget loads only after the visitor presses "Show Yelp reviews", so nothing from that site loads before they choose. Where to find codes: Yelp (the three-dot menu on a review, then "Embed review"), Zillow (the Reviews widget or Lender Reviews API), BBB (the Dynamic Seal, which shows the rating but not review text), Google (no official embed; use a review-widget service connected to your Business Profile).

## 6. Reuse on other pages

- Paste the whole block again on each page and change the JSON for that page (different heading, different reviews).
- Several copies on one page work; each keeps its own data.
- To change the look everywhere, edit the colours at the top of the `<style>` (the `--rv-...` variables on `.rv`), then paste the updated block on each page. If you use it on many pages, a theme or code-snippet plugin that outputs the style once is tidier.
- To match another site's colours: `--rv-navy` (headings, buttons), `--rv-gold` (accent line), `--rv-blue` (links), `--rv-star` (stars), `--rv-tint` (background).

## 7. Keep it accurate and compliant

Do this before the section goes live and each time you update it:

- **Source of truth.** Every review should be traceable to a link on the platform. Keep a spreadsheet of review, platform, date, link and who approved it.
- **Refresh.** Check ratings, counts and reviews at least monthly. Reviews get removed or edited, and counts change.
- **Be fair about the selection.** Showing only 5-star reviews next to a rating that covers every review can mislead. Show a fair mix, or say plainly that these are selected, as the default note does. Compliance should approve the wording.
- **Whose reviews.** If the reviews are about a company or other loan officers, say so; do not present them as about one person.
- **No promises.** Do not add claims such as rates, speed or approval odds that a review does not itself support, and check your lending-advertising rules for testimonials.
- **Permission.** Confirm you may show each reviewer's name and words under the platform's terms.

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| The section shows nothing | The JSON has a typo: a missing comma, a stray comma at the end of a list, or an unescaped double quote inside a text. Open the browser console (F12); the page shows nothing if the JSON cannot be read. Paste the JSON into a JSON checker to find the line. |
| Odd line breaks or paragraphs inside the data | The editor reformatted it. Use a Custom HTML block (WordPress) or an HTML widget, never a text or paragraph block. |
| The script does not run | Some security or optimisation plugins strip or delay inline scripts. Exclude the page from script minify, defer or sanitise settings, or allow inline scripts. |
| A theme's style changes the look | Raise specificity by prefixing `.rv` rules with your page wrapper, or set `font-family` and sizes on `.rv`. |
| Reviews do not appear in search results | The cards are drawn by script, so search engines may not read them as page text. That is fine. Do not add review markup for your own business; Google generally does not use self-published reviews for rich results. |
| Arrows or dots do nothing in a preview | Some builders block scripts in editor previews. Check on the published page. |
