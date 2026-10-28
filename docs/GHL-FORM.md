# Sending the funnel form to GoHighLevel (GHL)

The funnel form is already wired to post to any URL set as `FORM_ENDPOINT` in `config/site.json`. For GoHighLevel the URL is an **Inbound Webhook** trigger.

## 1. In GoHighLevel (your account)

1. Automation, **Workflows**, **Create workflow**, start from scratch. Name it "FinanceMyADU funnel lead".
2. Add trigger **Inbound Webhook**. Copy the **Webhook URL** it shows (it looks like `https://services.leadconnectorhq.com/hooks/...`).
3. Send us that URL (see step 2). After the first lead or test arrives, return to the trigger and choose the sample request so the field names show up for mapping.
4. Add action **Create/Update Contact** and map:
   - First name = `first_name`, Last name = `last_name`, Email = `email`, Phone = `phone`
   - Contact source = `source`
   - Put `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `page_url`, `referrer`, `submitted_at` and `consent_text` into custom fields (create them first under Settings, Custom Fields) or into a note.
5. Add what you want next: tag the contact (for example `financemyadu-funnel`), start your follow-up, notify the loan officer, add to a pipeline.
6. Publish the workflow.

## 2. On the site

Set `"FORM_ENDPOINT"` in `config/site.json` to the webhook URL, commit and push to `main`. The site redeploys in about a minute. (Or ask Claude to do it.)

## 3. What the form sends

A normal form post (`application/x-www-form-urlencoded`) with these fields:
`name`, `full_name`, `first_name`, `last_name`, `email`, `phone`, `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `source` ("FinanceMyADU funnel"), `page_url`, `referrer`, `submitted_at` (UTC time), `consent_given` ("yes") and `consent_text` (the exact consent sentence shown next to the button), plus an empty `website` field that is a spam trap.

## 4. Things to know

- **The browser cannot read GHL's reply.** The form is sent in "no-cors" mode so it works even if GHL does not allow browser requests. The thank-you message shows once the request leaves the page; a rejected request on GHL's side would not be noticed by the visitor. Check the workflow's execution log after the first leads.
- **The webhook URL is visible in the page source.** That is how a web form has to work. Anyone who finds it could post fake leads. The spam trap blocks simple bots; in the workflow you can add an **If/Else** that skips contacts with no phone or email, and GHL lets you regenerate the URL if it is abused.
- **Consent.** The consent sentence and time are saved with every lead. Compliance still has to approve the final wording.
- **Test it.** Submit the form yourself with a test name and check the contact and the workflow's execution log.
