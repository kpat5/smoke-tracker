# Smoke Tracker — Architecture & Data Schemas

## 1. Stack Decision

**Flutter (frontend) + AWS serverless (backend).** Chosen for near-zero hosting cost at hobby scale (stays within AWS's permanent Always Free quotas) and because the goal includes learning AWS along the way.

## 2. Backend Architecture

- **API Gateway (HTTP API, not REST API)** — cheaper and simpler than the older REST API type, and has a built-in JWT authorizer that plugs directly into Cognito with no custom authorizer code needed.
- **AWS Lambda (Node.js, `nodejs22.x` runtime)** — one function per route, written in JavaScript. Node.js is arguably the most common Lambda + DynamoDB pairing (excellent AWS SDK v3 support via `@aws-sdk/lib-dynamodb`, fast cold starts, and API Gateway's proxy integration maps onto a plain `exports.handler` function with no adapter layer needed — unlike some other languages/frameworks).
- **DynamoDB** — `Users` and `LogEntries` tables (schemas below). Stays within the Always Free tier (25GB storage, 200M requests/month) indefinitely at this app's scale.
- **Cognito User Pool** — handles sign-up/sign-in/token refresh directly; Flutter talks to Cognito's own APIs for auth rather than routing auth through custom Lambdas. Free for up to 50,000 monthly active users.
- **Infrastructure as code: AWS SAM** — defines every Lambda, the API Gateway routes, both DynamoDB tables, and the Cognito User Pool in one `template.yaml`. `sam build && sam deploy` ships the whole backend; `sam local invoke` lets you test a Lambda on your laptop without deploying, which matters a lot when learning since the feedback loop stays fast.
- **CI/CD: GitHub Actions** running `sam deploy` on push to `main` — free for this usage level and a natural next thing to learn once the manual deploy flow is familiar.

**Cost at this scale:** effectively $0/month indefinitely, since Lambda, API Gateway, DynamoDB, and Cognito all stay inside their permanent Always Free quotas for a personal-scale app. Cost only enters the picture if usage grows far beyond a solo/friends-and-family app, at which point it's a good problem to have.

## 3. Data Model (DynamoDB)

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

Keying `LogEntries` by its own `logId` (rather than a composite `userId#occurredAt` key) keeps single-item edit/delete simple — the app already has the `logId` from whatever list it just rendered, so no key reconstruction is needed. The GSI (`userId` + `occurredAt`) is what makes range queries fast: "today's count," "this week's stats," the entries list, and the weekly recap all become a single `Query` against the GSI with a `BETWEEN` on `occurredAt`, no scanning.

At this app's per-user data volume (even a heavy smoker tops out around 15,000 entries/year), there's no need for extra GSIs on `triggerTag` etc. — a Lambda can just pull the date-range query result and aggregate breakdowns (by trigger, by time-of-day) in memory before returning it to the app.

**Key design decision:** `costSnapshot` is stored per log entry, not derived live from the user's current `packPrice`. If cost were computed live, editing the pack price later would silently rewrite all historical stats. Snapshotting at log time keeps history accurate.

**Deliberately excluded from MVP:** no location data — not needed for any current feature, and avoiding it sidesteps unnecessary sensitive-data handling for what's meant to be a lightweight, fun app.

**Forward compatibility:** a `Groups` table (and a `GroupMemberships` table, likely keyed by `groupId` with a GSI on `userId`) can be added in phase 2 without touching `Users` or `LogEntries`.

## 4. API Routes

- `POST /logs` — create a log entry (covers both quick-log and backdated entries)
- `GET /logs?from=&to=` — fetch entries in a range, used by Home ("today"), the Entries list, Stats, and the weekly recap
- `PATCH /logs/{logId}` — edit an entry
- `DELETE /logs/{logId}` — delete an entry
- `GET /user` / `PUT /user` — read/update profile (currency, pack price, personality, roast intensity)
- `GET /stats?range=week|month|all` — pulls the relevant `LogEntries` via the GSI and returns pre-aggregated totals/breakdowns, so the Flutter app stays thin and battery-friendly rather than aggregating hundreds of raw entries on-device.

## 5. Repo Layout

```
/mobile                          # Flutter app
/backend/functions/<route-name>  # one folder per Lambda
/infrastructure/template.yaml    # the SAM template
```

A structure that maps cleanly onto how Claude Code would scaffold and navigate the project.
