# Smoke Tracker App — MVP Project Brief

## 1. Concept

A mobile app (iOS + Android) for people to log each cigarette they smoke and see the harm, cost, and patterns reflected back at them — but framed as a **fun, well-designed, personality-driven app, not a medical or quit-smoking tool**.

**Core stance: strictly neutral.** The app does not encourage smoking and does not encourage quitting. It never tells the user to cut back, never praises them for smoking more or less, and never uses guilt or health-scare language. All copy reacts to *patterns and numbers*, never to the behavior itself. Think "witty expense tracker with a personality," not a coach or a doctor.

Groups/social features (friend leaderboards, shared challenges) are explicitly **out of MVP scope** and planned for phase 2, once the solo tracking loop is validated.

## 2. Core Loop

1. User taps a single big button: "I just smoked." Defaults to logging *right now*, saved in under 5 seconds.
2. Optionally, before or after saving, they can: change the time (supports backdating — "earlier today," "yesterday," or a full date/time picker), tag a trigger (stress, boredom, social, after a meal, coffee, alcohol, custom), and add a short note.
3. The app reflects stats back: today's count, running cost (based on pack price + currency set at onboarding), and longer-term trends — always through the lens of the user's chosen mascot personality.
4. A weekly recap (Spotify-Wrapped style) auto-generates a shareable card summarizing the week's count, cost, and top patterns.

## 3. Mascot Personalities

One flexible mascot character (a single rigged design — e.g. a smoke-wisp/blob shape) with **4 selectable personality skins**, chosen at onboarding and changeable anytime in settings. Using one character design avoids gendering the mascot and keeps art production simple for MVP.

A **roast intensity** slider (mild / medium / savage) modulates wit within whichever personality is chosen — but at no setting does any personality cross into judgment about quitting or continuing.

### Deadpan
Flat, dry, mildly unimpressed by everything.
- "Nothing logged yet today. Groundbreaking."
- "Six. Same as yesterday. Consistency is a virtue, apparently."
- "Eleven today. I've stopped being surprised."
- "Adding one from three hours ago. Time travel, but for cigarettes."
- "42 this week, ₹840 spent. I ran the numbers twice. They didn't improve."
- "100 logs. There should be a certificate. There isn't."

### Chaotic
Unhinged, over-the-top, treats every stat like breaking news.
- "The count is currently ZERO. Suspicious. I'm watching."
- "LOG #7 HAS ENTERED THE CHAT."
- "We are DOUBLE DIGITS today. Someone alert the local news."
- "Ooh, a mystery cigarette from the past. The plot thickens."
- "This week: 38 logged, ₹760 gone, and 3 logs suspiciously all at 4:47pm. Coincidence? I think NOT."
- "100 LOGS. WE'VE UNLOCKED SOMETHING. I don't know what. But something."

### Wholesome-but-sarcastic
Warm, a little teasing, feels like a friend poking fun, not a judge.
- "Quiet day so far. I respect it, or I don't care either way, hard to say."
- "Logged. No notes, just vibes."
- "Busy one today, huh. Hope at least the coffee was good."
- "Got it, backfilled from earlier — better late than never, I guess, or whatever."
- "42 this week, ₹840 spent. Mostly around 3pm. You and 3pm have a whole thing going on."
- "100 logs in the books. That's a lot of data. Thanks for the spreadsheet material."

### Zen (mock-profound)
Calm, treats mundane stats like ancient wisdom, deadpan absurdity via faux-philosophy.
- "The day is young. The count is zero. All is still."
- "One entry, like a leaf falling. The log accepts it without judgment."
- "Eleven today. The universe does not count. Only you do."
- "A moment from the past, now recorded. Time is a construct anyway."
- "42 this week. ₹840 spent. Numbers rise, numbers fall. The chart remains."
- "100 logs. A century of small moments. The mascot bows."

*(These are starter lines to validate tone — expect to expand the copy bank per scenario: empty days, streaks, trigger-tag-specific reactions, currency-specific jokes, etc.)*

## 4. Data Model (DynamoDB)

Two tables, designed around the actual access patterns the app needs (fetch a user's profile, create a log, fetch a user's logs in a date range, edit/delete a specific log) rather than a relational join model.

```
Users table
  PK: userId (Cognito sub)
  ---
  currencyCode          // e.g. "INR", "USD"
  currencySymbol        // e.g. "₹", "$"
  packPrice              // current price, editable anytime
  cigarettesPerPack
  personality             // deadpan | chaotic | wholesome | zen
  roastIntensity          // mild | medium | savage
  timezone
  createdAt

LogEntries table
  PK: logId (UUID, generated on create)
  GSI1: userId (PK) + occurredAt (SK)   // powers "get my logs between date A and B"
  ---
  userId
  occurredAt             // when they actually smoked — editable, can be backdated
  loggedAt                // when they actually entered it in the app
  costSnapshot             // price-per-cigarette AT TIME OF LOG (packPrice / cigarettesPerPack)
  currencySnapshot          // in case currency is ever changed later
  triggerTag               // nullable — stress | boredom | social | after_meal | coffee | alcohol | custom | none
  customTagLabel           // only used if triggerTag = custom
  note                      // optional free text
  createdVia                // "quick" | "backdated" — internal analytics only
```

Keying `LogEntries` by its own `logId` (rather than a composite `userId#occurredAt` key) keeps single-item edit/delete simple — the app already has the `logId` from whatever list it just rendered, so no key reconstruction is needed. The GSI (`userId` + `occurredAt`) is what makes range queries fast: "today's count," "this week's stats," and the weekly recap all become a single `Query` against the GSI with a `BETWEEN` on `occurredAt`, no scanning.

At this app's per-user data volume (even a heavy smoker tops out around 15,000 entries/year), there's no need for extra GSIs on `triggerTag` etc. — a Lambda can just pull the date-range query result and aggregate breakdowns (by trigger, by time-of-day) in memory before returning it to the app.

**Key design decision:** `costSnapshot` is stored per log entry, not derived live from the user's current `packPrice`. If cost were computed live, editing the pack price later would silently rewrite all historical stats. Snapshotting at log time keeps history accurate.

**Deliberately excluded from MVP:** no location data — not needed for any current feature, and avoiding it sidesteps unnecessary sensitive-data handling for what's meant to be a lightweight, fun app.

**Forward compatibility:** a `Groups` table (and a `GroupMemberships` table, likely keyed by `groupId` with a GSI on `userId`) can be added in phase 2 without touching `Users` or `LogEntries`.

## 5. Screens & Flow

**Onboarding (once):**
Brief neutral intro → pick mascot personality (with live line previews) → set currency, pack price, cigarettes per pack (auto-computes cost per cigarette) → set roast intensity → optional "log any from earlier today?" catch-up step → lands on Home.

**Home (Tab 1):**
Mascot avatar reacting with a personality-flavored line based on current state → today's count and cost → one large primary button to log "now" → smaller secondary control to "log earlier" (opens the same modal with the date/time picker expanded).

**Quick-log modal:**
Two depths. Tap once = saved instantly with `occurred_at = now`. Expand for more: time picker (shortcuts for "earlier today" / "yesterday" + full picker), trigger tag chips, optional note. All fields beyond the single tap are optional.

**Stats (Tab 2):**
Time-range switch (week / month / all-time) → charts for count over time, cost over time, breakdown by trigger tag, time-of-day/day-of-week patterns. Weekly recap (shareable card) surfaces here, either auto-prompted when a new week completes or generated on demand.

**Settings (Tab 3):**
Edit currency/pack price/cigarettes-per-pack (with a note that past entries keep their original cost snapshot) → change mascot personality/roast intensity anytime → export data as CSV → delete account/data → short "why this app is neutral" statement.

Three tabs total (Home / Stats / Settings) — no fourth tab needed since recap lives inside Stats.

## 6. Tech Direction

**Decision: Flutter (frontend) + AWS serverless (backend).** Chosen for near-zero hosting cost at hobby scale (stays within AWS's permanent Always Free quotas) and because the user explicitly wants to learn AWS along the way.

**Frontend:** Flutter, targeting iOS + Android from one codebase.

**Backend architecture:**
- **API Gateway (HTTP API, not REST API)** — cheaper and simpler than the older REST API type, and has a built-in JWT authorizer that plugs directly into Cognito with no custom authorizer code needed.
- **AWS Lambda (Python)** — one function per route. Python recommended for readability while learning; swap for Node.js later with no other architecture changes if preferred.
- **DynamoDB** — `Users` and `LogEntries` tables as described in section 4. Stays within the Always Free tier (25GB storage, 200M requests/month) indefinitely at this app's scale.
- **Cognito User Pool** — handles sign-up/sign-in/token refresh directly; Flutter talks to Cognito's own APIs for auth rather than routing auth through custom Lambdas. Free for up to 50,000 monthly active users.
- **Infrastructure as code: AWS SAM** — defines every Lambda, the API Gateway routes, both DynamoDB tables, and the Cognito User Pool in one `template.yaml`. `sam build && sam deploy` ships the whole backend; `sam local invoke` lets you test a Lambda on your laptop without deploying, which matters a lot when learning since the feedback loop stays fast.
- **CI/CD: GitHub Actions** running `sam deploy` on push to `main` — free for this usage level and a natural next thing to learn once the manual deploy flow is familiar.

**Suggested routes (one Lambda each):**
- `POST /logs` — create a log entry (covers both quick-log and backdated entries)
- `GET /logs?from=&to=` — fetch entries in a range, used by Home ("today"), Stats, and the weekly recap
- `PATCH /logs/{logId}` — edit an entry
- `DELETE /logs/{logId}` — delete an entry
- `GET /user` / `PUT /user` — read/update profile (currency, pack price, personality, roast intensity)
- `GET /stats?range=week|month|all` — pulls the relevant `LogEntries` via the GSI and returns pre-aggregated totals/breakdowns, so the Flutter app stays thin and battery-friendly rather than aggregating hundreds of raw entries on-device.

**Suggested repo layout:** `/mobile` (Flutter app), `/backend/functions/<route-name>` (one folder per Lambda), `/infrastructure/template.yaml` (the SAM template) — a structure that maps cleanly onto how Claude Code would scaffold and navigate the project.

**Cost at this scale:** effectively $0/month indefinitely, since Lambda, API Gateway, DynamoDB, and Cognito all stay inside their permanent Always Free quotas for a personal-scale app. Cost only enters the picture if usage grows far beyond a solo/friends-and-family app, at which point it's a good problem to have.

## 7. Roadmap

- **Phase 0:** Clickable prototype (Figma or similar) to validate mascot design and copy tone before writing app code.
- **Phase 1 (MVP):** Onboarding → quick-log → home → stats → weekly recap → settings, in that build order so there's always a demoable app.
- **Phase 2:** Groups/social — friend leaderboards, shared challenges, cross-user comparisons (will need a reference-currency approach if comparing spend across different currencies).
- **Phase 3+:** Additional gamification (achievements, more mascot personalities), smart notifications, other product types (vape, cigars), deeper insights/integrations.

## 8. Open Questions (not yet decided)

- Can users edit or delete a log entry after saving it? (Recommended: yes — mislogs and accidental taps are inevitable, and refusing to allow correction would be a bad first impression.)
- Is mascot personality locked at onboarding or freely switchable in settings? (Switchable is more fun but multiplies the copy-writing workload by 4x for every future scenario.)
- Does the roast-intensity slider apply independently within each personality, or is personality alone enough variety for MVP?
- Should copy react to trigger tags specifically (e.g., different line for "stress" vs "coffee") once that data exists, or stay generic for v1 to keep the copy bank manageable?
