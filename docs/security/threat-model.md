# Threat model (v1 — auth plan_5)

For: anyone changing auth, permissions, uploads, or rendering; update
this when a new surface ships.

## Assets

Cue content (potentially "my password is X" in comments — encrypted per
ADR 0011), user emails, session cookies, AR encryption keys + Rails
credentials, the Postgres instance and its backups.

## Actors

Anonymous internet (bots, credential stuffers) · authenticated
requesters in the wrong org (the tenancy boundary, ADR 0010) · curious
org members (role boundaries) · support staff (break-glass, audited) ·
whoever steals a backup or the VPS disk.

## Surfaces and their standing defenses

| Surface                            | Defense                                                                                       | Verified by                                            |
| ---------------------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Login/signup/reset endpoints       | throttles, lockout, no-enumeration responses, timing parity                                   | rate_limiting/lockout/sessions specs (all `:negative`) |
| Tokens (verify/login/reset/unlock) | hashed at rest, single-use, purpose-scoped, TTL, attempt caps                                 | auth_token + flow specs                                |
| Session cookies                    | signed, httponly, SameSite=Lax, server-side 7-day absolute expiry, rotation on login          | security_headers + sessions specs                      |
| XSS                                | strict CSP (default-src 'none'), React escaping, no dangerouslySetInnerHTML (react-doctor)    | system suite runs under the real CSP                   |
| SQLi / mass assignment             | AR parameterization, strong params, Brakeman                                                  | CI                                                     |
| Cross-tenant access                | acts_as_tenant + schema conformance + (coming) cross-org 404 sweep + composite FKs            | tenant_schema_conformance spec                         |
| Supply chain                       | pnpm minimumReleaseAge/no-downgrade, bundler-audit, pnpm audit, gitleaks, pinned react-doctor | CI + weekly scan                                       |

## Standing additions queue

- Stripe webhooks (billing plan_3): replay + signature-stripping abuse.
- File uploads (cues plan_5): content-type laundering, EXIF, quota abuse.
- Markdown rendering (initiatives plan_3): image/link injection.
