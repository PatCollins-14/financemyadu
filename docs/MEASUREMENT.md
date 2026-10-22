# Measurement

## Analytics (off by default)
- `ANALYTICS_ID` is `GTM-TQ8C7WLM`: Pat chose to reuse the main site's Google Tag Manager container (chat, 2026-10-23). The funnel shows a small consent bar and loads nothing until a visitor presses Accept. Deny is the default if they ignore it. No cookie or network call happens before Accept.
- The container is shared with the main site, which keeps it behind Complianz consent. Before launch, someone with GTM access should open the container and list its tags and triggers. I could not see inside it. If it fires advertising or Facebook pixel tags, the funnel's consent wording must cover them and the tags should be limited to this page where possible. Add the five funnel events (below) as GTM triggers; the funnel pushes them to `dataLayer` after consent.
- Never put the ID in a file that is committed with secrets. It is a public ID, but it is still set by environment variable or `config/site.json`.

## Events (sent only after consent)
| Event | Fires when |
|---|---|
| `quiz_start` | the visitor first focuses or advances the quiz |
| `quiz_complete` | the quiz endpoint accepts the submission |
| `consult_booked` | the visitor clicks a "Book a call" link. This measures the click, not a confirmed booking. A confirmed booking needs a redirect or webhook from the booking tool. |
| `application_link_click` | the visitor clicks the application link (shown only after Pat confirms the link) |
| `phone_click` | the visitor clicks a phone link |

## UTM convention
`utm_source=chatgpt`, `utm_medium=cpc`, `utm_campaign=adu-financing`, `utm_content=<ad variant>` (for example `T1-D1`). The quiz copies these from the URL into hidden fields so each lead carries its source. Hub links to the funnel use `utm_source=adu-hub&utm_medium=organic&utm_campaign=hub-cta`.

## Reading chatgpt.com referral traffic
In GA4: Reports > Acquisition > Traffic acquisition, then filter Session source containing `chatgpt.com`. Ad clicks carry the UTM tags above. Organic citations from ChatGPT search may arrive as `chatgpt.com` referrals with no UTM, so look at both. Referral share numbers published elsewhere conflict; treat your own data as the only reliable source.

## AI visibility: the question panel
`measurement/question-panel.csv` has 25 questions across 5 platforms (ChatGPT, Gemini, Claude, Perplexity, Google AI Mode). AI answers change on almost every run, so one test proves nothing. Run each question several times per platform on a fixed schedule (for example weekly), record whether Pat's site is mentioned or cited, and track the share of runs where it is. Treat results as directional.

## Monthly scorecard
`measurement/monthly-scorecard.md`.
