# Smoke Tracker — MVP Project Brief

## 1. Concept

A mobile app (iOS + Android) for people to log each cigarette they smoke and see the cost and patterns reflected back at them — but framed as a **fun, well-designed, personality-driven app, not a medical or quit-smoking tool**.

**Core stance: strictly neutral.** The app does not encourage smoking and does not encourage quitting. It never tells the user to cut back, never praises them for smoking more or less, and never uses guilt or health-scare language. All copy reacts to *patterns and numbers*, never to the behavior itself. Think "witty expense tracker with a personality," not a coach or a doctor.

Groups/social features (friend leaderboards, shared challenges) are explicitly **out of MVP scope** and planned for phase 2, once the solo tracking loop is validated.

## 2. Core Loop

1. User taps a single big button: "I just smoked." Defaults to logging *right now*, saved in under 5 seconds.
2. Optionally, before or after saving, they can: change the time (supports backdating — "earlier today," "yesterday," or a full date/time picker), tag a trigger (stress, boredom, social, after a meal, coffee, alcohol, custom), and add a short note.
3. The app reflects stats back: today's count, running cost (based on pack price + currency set at onboarding), and longer-term trends — always through the lens of the user's chosen mascot personality.
4. A weekly recap (Spotify-Wrapped style) auto-generates a shareable card summarizing the week's count, cost, and top patterns.

Full mascot personalities, copy bank, and screen-by-screen flow live in `design-doc.md`. Full tech stack and data schemas live in `architecture-and-schemas.md`.

## 3. Roadmap

- **Phase 0:** Clickable prototype / visual mockups (in progress) to validate mascot design and copy tone before writing app code.
- **Phase 1 (MVP):** Onboarding → quick-log → home → entries list → stats → weekly recap → settings, in that build order so there's always a demoable app.
- **Phase 2:** Groups/social — friend leaderboards, shared challenges, cross-user comparisons (will need a reference-currency approach if comparing spend across different currencies).
- **Phase 3+:** Additional gamification (achievements, more mascot personalities), smart notifications, other product types (vape, cigars), deeper insights/integrations.

## 4. Open Questions (not yet decided)

- Is mascot personality locked at onboarding or freely switchable in settings? (Switchable is more fun but multiplies the copy-writing workload by 4x for every future scenario.)
- Does the roast-intensity slider apply independently within each personality, or is personality alone enough variety for MVP?
- Should copy react to trigger tags specifically (e.g., different line for "stress" vs "coffee") once that data exists, or stay generic for v1 to keep the copy bank manageable?
- Which mascot shape direction to commit to for real character art — see `design-doc.md` section on mascot art direction.
