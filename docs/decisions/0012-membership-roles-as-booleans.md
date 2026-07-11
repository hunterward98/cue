# 0012 — Membership model: boolean roles, three states, no invited row

- **Date:** 2026-07-11 (org plan_2 implementation; critique ratified by
  user 2026-07-11: "Great callout … multiple org owners is acceptable,
  probably preferable for larger customers")
- **Status:** accepted

## Context

Org plan_2 originally drew a `role` enum (owner / board_owner /
requester) plus a `board_owner_also` boolean on owner rows. The plan
critique flagged that as two ways to be a board owner — every "all board
owners" query would need `role = 'board_owner' OR (role = 'owner' AND
board_owner_also)`, and someone would forget. The plan also listed an
`invited` membership state, but plan_3's refined design gives
invitations their own model (an invitee without an account can't have a
membership row, which requires `user_id NOT NULL`).

## Decision

1. **Roles are two independent booleans** on Membership: `owner` and
   `board_owner`. Requester = both false. One source of truth per role;
   tier-limit counts are single-column queries (`WHERE board_owner`).
   Multiple owners per org are expected, not tolerated.
2. **Support/staff is structurally inexpressible as a membership** — no
   role column exists to hold it (negative-tested), keeping the
   support-admin plan's global `User.staff` flag the only staff bit.
3. **Membership has three states** — `pending_approval`, `active`,
   `deactivated` (DB CHECK + transition validations). The invited
   lifecycle lives entirely on org plan_3's Invitation model; a denied
   join request is destroyed, not tombstoned.

## Why

Fewer representations to disagree with each other; the 100% branch gate
also forbids dead states — an `invited` membership state would be
unreachable code the day Invitation lands.

## Revisit when

A role appears that isn't a boolean grant (e.g. per-board permissions) —
that's a join table, not a third flag.
