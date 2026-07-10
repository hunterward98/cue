# cues — Child Plan 5: File Uploads

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; billing entitlements seam (tier size limits);
  manual step: R2 bucket + credentials (shared with database plan_4's
  backup bucket setup)
- **Last updated:** 2026-07-08

## Goal

Requesters attach the flyer, the photo, the screenshot — from a phone
camera roll as easily as a desktop. Stored cheap (R2), served safely
(signed URLs), limited by tier (2MB basic; premium/enterprise per billing
Q2, rec 25MB).

## Design

- **Active Storage + Cloudflare R2** (S3-compatible, zero egress fees —
  the cost-dominant term for a design-file workload; ADR). Buckets:
  uploads (this plan), backups (database plan_4) — separate credentials.
- **Direct uploads** browser → R2 (presigned), keeping the VPS out of the
  byte path; attachment record confirmed server-side after upload
  completes. Orphan sweep job for unconfirmed blobs (>24h).
- **Validation server-side at attach time** (client hints are UX only):
  size vs `Entitlements#limit_for(:upload_bytes)`; content-type allowlist
  (images, pdf, common design/office formats — documented list; no
  executables/scripts/archives at v1, see Q1); magic-byte sniff must match
  declared type (spoof negative test); max attachments per cue (20).
- **Serving:** signed expiring URLs, `Content-Disposition: attachment`
  for everything except image previews; image previews/thumbnails via
  vips variants, EXIF stripped (location privacy — these are phone
  photos). No public bucket access (preflight-asserted).
- **Deletion:** attachment removal by cue-modifiers (plan_2 policy);
  blobs purged async; cue deletion (rare) purges attachments.
- Virus scanning: deferred with a documented posture (allowlist + no
  executables + attachment disposition covers the realistic risk at this
  scale); revisit at auth plan_5's phase review (tracked there).

## Implementation steps

- [ ] R2 buckets + credentials + Active Storage config (manual step
      rider) + dev disk service.
- [ ] Direct upload flow + confirm endpoint + orphan sweep.
- [ ] Validation layer (size seam, allowlist, sniffing, count cap).
- [ ] Variants + EXIF stripping + signed serving.
- [ ] Upload UI: drag-drop (desktop), camera-roll/file picker (mobile),
      progress, failure states — component in the library (gallery entry).
- [ ] Deletion + purge paths.

## Tests

- Negative: 3MB file on basic → rejected server-side even with tampered
  client; content-type spoof (exe as .png) → rejected by sniff; 21st
  attachment → rejected; unsigned/expired URL fetch → denied; cross-org
  signed URL reuse → denied; EXIF GPS present in served variant → fail.
- System: mobile camera-roll upload path (Capybara file attach at mobile
  viewport), progress + failure rendering.

## Open questions

1. **v1 type allowlist breadth** — (a) images + PDF + docx/xlsx/pptx +
   txt/md **8/10**: covers design/marketing/IT reality, low risk;
   (b) images + PDF only **6/10**: safest, but "attach the Word brief" is
   a day-one IT/marketing need; (c) anything but executables **3/10**:
   allowlists beat denylists.
2. **Per-org storage quota** — (a) generous soft quota per tier
   (e.g. 5GB basic / 50GB premium), support-visible, enforced later
   **7/10**: prevents pathological cost without building enforcement UI
   now; (b) hard quotas at v1 **5/10**: more billing surface before
   evidence of need; (c) none **4/10**: one org can become our whole R2
   bill.

## Critique

*Reviewed 2026-07-09.*

- **EXIF stripping as designed has a hole: variants are stripped, the
  original isn't — and "download" serves the original.** A requester's
  phone photo keeps its GPS coordinates for anyone in the org who
  downloads it. Fix: strip metadata **at ingest** for image types
  (re-encode the original via vips after the direct upload confirms;
  replace the blob), variants inherit cleanliness for free. Alternative
  if re-encoding originals feels lossy for designers (it can be, for
  print-resolution files): keep originals untouched but serve a
  stripped "web original" by default and gate the true original behind
  an explicit "download original (includes metadata)" action. Recommend
  the first for MVP simplicity; designers needing pristine files is a
  premium-tier refinement to revisit.
- R2 + Active Storage direct upload requires bucket CORS configuration —
  make it an explicit implementation step (it's the #1 "uploads work
  locally, fail in prod" gotcha; pre-empt it rather than earn the
  gotcha entry).
- Content-type sniffing + allowlist + attachment disposition: sound.
  The deferred-virus-scanning posture is defensible with this
  allowlist; keep the auth plan_5 phase-review re-check as planned.
- No further critique.
