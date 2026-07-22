# Smoke Tracker — Design Doc

## 1. Visual Direction (validated)

Warm cream background, rounded white cards, mild-orange accent color for the primary CTA button and active nav state. Two mascot shape directions were mocked up and both read well against this palette:

- **1a — Blob mascot:** a soft, simple rounded shape. Easier to animate/re-skin across the 4 personalities since the form is minimal.
- **1b — Wisp mascot:** a layered smoke-curl shape with a small secondary puff, slightly more distinctive and on-theme (literally shaped like smoke) but more complex to illustrate and re-skin 4 ways.

**Open decision:** pick one direction to commit to for real character art (see section 2).

## 2. Mascot Art Direction

The mockups currently use a generic emoji-style smiley face as a placeholder. **This needs to be replaced with an actual illustrated character** with its own distinct linework, expressions, and color treatment — not a system emoji — so the mascot reads as a designed character with a personality, not a placeholder smiley. Each of the 4 personalities (below) should get its own expression/pose/color variant of whichever base shape (blob or wisp) is chosen, so switching personality in settings visibly changes the character, not just the copy.

## 3. Mascot Personalities & Copy Bank

One flexible mascot character with **4 selectable personality skins**, chosen at onboarding and changeable anytime in settings. A **roast intensity** slider (mild / medium / savage) modulates wit within whichever personality is chosen — but at no setting does any personality cross into judgment about quitting or continuing (see the neutral-stance rule in `mvp-project-brief.md`).

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
- "LOG #1 HAS ENTERED THE CHAT."
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

*(Starter lines to validate tone — expect to expand the copy bank per scenario: empty days, streaks, trigger-tag-specific reactions, currency-specific jokes, etc.)*

## 4. Screens & Flow

**Onboarding (once):**
Brief neutral intro → pick mascot personality (with live line + character previews) → set currency, pack price, cigarettes per pack (auto-computes cost per cigarette) → set roast intensity → optional "log any from earlier today?" catch-up step → lands on Home.

**Home (Tab 1) — revised:**
Mascot card up top reacting with a personality-flavored line based on current state → "Today" stat tile (count) and "Spent today" stat tile (cost) side by side → one large primary button "I just smoked" → smaller "Log earlier ›" link below it.
**Change from the mockup:** the "Recent" entries list is removed from Home entirely. Home stays a fast, uncluttered action screen — glance at the mascot, glance at two numbers, tap the button, done. This matches the earlier decision to keep the one-tap action as the whole point of Home.

**Entries (Tab 2) — new:**
The full scrollable log list that used to live on Home now lives here as its own tab: each row shows time, trigger tag, and cost, matching the mockup's row style ("12:44 AM — Coffee — ₹15", etc). Tapping a row opens it for edit (time, trigger, note) or delete. This is also the natural home for a search/filter control later (by trigger tag, by date range) without crowding Home.

**Quick-log modal:**
Two depths. Tap once = saved instantly with `occurredAt = now`. Expand for more: time picker (shortcuts for "earlier today" / "yesterday" + full picker), trigger tag chips, optional note. All fields beyond the single tap are optional. Accessible from both the Home CTA and the "Log earlier ›" link (the latter opens it pre-expanded to the time picker).

**Stats (Tab 3):**
Time-range switch (week / month / all-time) → charts for count over time, cost over time, breakdown by trigger tag, time-of-day/day-of-week patterns. Weekly recap (shareable card) surfaces here, either auto-prompted when a new week completes or generated on demand.

**Settings (Tab 4):**
Edit currency/pack price/cigarettes-per-pack (with a note that past entries keep their original cost snapshot) → change mascot personality/roast intensity anytime → export data as CSV → delete account/data → short "why this app is neutral" statement.

**Bottom nav: Home / Entries / Stats / Settings** — four tabs total, so the entries list gets its own dedicated space instead of competing with Home's single-action purpose.
