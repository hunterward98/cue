# Cue voice guide (v1 — theming plan_5)

For: anyone writing a string that a user will read — copy, empty states,
errors, emails, tutorial steps.

## The voice in one line

A little snarky, never mean. Cue talks like a sharp coworker who likes
you, not a SaaS landing page and not a comedian. The master plan's own
example is the north star:

> "Normal people just call this a ticket; you can do that if you really
> want."

That's the register: dry, a little wry, respectful of the reader's
intelligence, never at their expense.

## Rules

1. **Snark seasons, it isn't the meal.** At most one wink per screen.
   If every line is trying to be funny, none of them land — and the
   screen stops being usable copy and starts being a bit.
2. **Never at the user's expense.** The joke is about the software, the
   absurdity of enterprise ticketing systems, or Cue itself being a
   little precious about a small thing — never about the user being
   slow, wrong, or bad at their job. "That code didn't work" is fine;
   "you typed that wrong" is not.
3. **Plain words over jargon.** Say "board" not "workspace instance."
   Say "request" not "artifact." If a normal person wouldn't say it out
   loud, don't print it.
4. **Snark-light zones: auth, billing, errors with real consequences.**
   Signing in, paying, losing data, getting locked out — these are
   moments of real user stress or real money. Be warm and clear, not
   funny. Save the personality for empty states, tutorial copy, and
   success moments, where a light touch actually helps.
5. **Destructive confirmations are dead serious.** "Delete this org?"
   and everything downstream of it (org plan_3's `ConfirmDialog`
   default variant) carries zero snark. No jokes on the way to
   `DROP TABLE`-adjacent decisions.
6. **A tutorial that needs more than 4 steps means the UI failed**
   (plan_5 critique). If the guided tour can't teach the feature in 4
   beats, the feature is too complicated, not the tutorial too short.
   Fix the UI before writing a longer tour.
7. **Validation and error copy lives in one place, not two** (plan_5
   critique). Server-generated errors (validation messages, Rails
   flash) arrive as Inertia props and render as-is — `strings.ts`
   never re-writes or duplicates them. One system decides the words for
   "why this failed," so the snark level can't drift between a
   client-side check and the server's version of the same rejection.
8. **"Mentions always notify" is not a promise to make in copy.** The
   mute setting (notifications plan_3) means "always" is never
   literally true — tutorial and preference copy says "you'll hear
   about it" or similar, not "always."

## Do / don't

| Situation             | Don't                                      | Do                                                                                                                                                             |
| --------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Introducing cues      | "Create a Ticket"                          | "Raise a cue — normal people call it a ticket, you can do that if you really want."                                                                            |
| Empty backlog         | "No items found."                          | "Nothing to see yet. When cues land, this is where they'll queue up — patiently." (already shipped, `org/home.tsx`)                                            |
| Sign-out confirmation | "Confirm Logout?"                          | "Signed out. The cues will wait." (already shipped, `sessions_controller.rb`)                                                                                  |
| Rate limit            | "429 Too Many Requests"                    | "Easy there. Too many attempts — wait a minute and try again." (already shipped, `rack_attack.rb`)                                                             |
| Deleting an org       | any joke                                   | "Delete this org? This can't be undone." — flat, clear, no wink                                                                                                |
| A validation error    | inventing a friendlier client-side rewrite | render the server's message as-is (rule 7)                                                                                                                     |
| Locked account        | "Account locked. Contact support."         | "Ten sign-in attempts in a row didn't work, so we locked your account — standard procedure, nothing personal." (already shipped, `auth_mailer/account_locked`) |

## String centralization

Decision: typed `strings.ts` modules per frontend feature, no i18n
runtime — see [ADR 0016](../decisions/0016-string-centralization.md) for
the full reasoning. Retrofitting the strings that already exist, and
adding the literal-string lint that keeps new ones out of JSX, is
deferred — see that ADR's "Revisit when."

## Tutorials (coach marks)

Deferred with the rest of plan_5's tutorial framework — two of the
three v1 tutorials teach screens (a board, the create-cue button) that
don't exist yet (cues and boards-workflow are both unreviewed). Building
the coach-mark component and the "what's a cue?" tutorial before cues
ships would mean guessing at UI that hasn't been designed. This doc's
rules apply the moment that work starts.
