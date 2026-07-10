# Manual Steps — Notifications & Email

- [ ] Decide provider: Postmark (recommended, ~$15/mo, best deliverability)
      vs Amazon SES (cheapest, more setup friction). Then create the account.
- [ ] Provide the sending domain (shared purchase with foundation/marketing
      plans) and add the DNS records (SPF, DKIM, DMARC) the plan_2 work will
      generate for you.
- [ ] Confirm the privacy stance in plan_1 "Key decisions" #2 (no sensitive
      content in email bodies) — it shapes every template.
