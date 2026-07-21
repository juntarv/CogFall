**Concept:** CogFall is an offline one-hand physics puzzle where you drop brass gears down a clockwork bay so their teeth mesh into an unbroken train that carries spin from the always-turning power spindle to every target, bringing each mechanism to life.

---

## 1. Game overview

CogFall is a SwiftUI shell wrapping a single SpriteKit scene. The core loop is
**aim → drop → mesh → power**:

- A **power spindle** at one anchor always turns. Drop gears so a settled gear
  lands within a tooth's reach of a neighbour — they **mesh** and spin as one.
- Chain meshed gears until the train reaches every **target spindle** (each
  drives a small brass fixture — a lark, an orrery ring, a sun). When all
  targets turn, the **mechanism comes alive** and the bay is solved.
- Gears come in three sizes: **Small / Medium / Large** = tooth count = radius
  = reach. A gear that lands overlapping another (no valid axle, or wrong
  spacing) **jams**: it wobbles, is discarded, and raises the **Heat** meter.
- Meshed gears alternate spin direction (parity). A target with a required
  direction adds a light logic layer in later bays.

**Win (Campaign bay):** every target spindle is powered.
**Lose:** the Heat meter fills (too many jams / bad drops) → bay resets.
**Overdrive (endless):** the bay grows taller, the spindle speeds up, and new
target lamps keep appearing; score by seconds-powered and gears meshed until
Heat maxes.

Scoring: `base per meshed gear × live spin multiplier + spare-gear bonus +
powered-time bonus`. Fewer gears used and zero jams award more of the 3 stars.

Two modes: **Campaign** (24 authored bays reached via the Conduit level map)
and **Overdrive** (endless, launched from the Conduit's bottom rail).

Launch arguments honoured: `-skipSplash`, `-demoMode` (fixed RNG + staged
spawn script), `-screenshotTour` (auto-cycles all screens, 3 s each, splash &
onboarding skipped, demo progress seeded).

---

## 2. Screens

Nine screens, matching the rendered designs in `design/`.

### 2.1 Splash — `design/splash.png`
**Purpose:** brand reveal while the app warms up (1.5 s via HomeView `.task`).
Purely visual, zero logic.
- Three interlocked brass/steel gears with a glowing hub, `COGFALL` wordmark,
  tagline "The gravity machine shop", and a winding "mainspring" progress bar.

### 2.2 Onboarding — `design/onboarding.png`
**Purpose:** teach the drop → mesh → power loop in 3 swipeable slides.
- Hero stage animates a ghost gear falling along a dashed trajectory into a
  meshed train beside a live power spindle.
- Copy card (eyebrow "How it works · N of 3", title, body). Progress dots.
- Buttons: **Next** (`next_button`) / on last slide **Start** (`start_button`);
  **Skip** top-right (`skip_button`). Completing sets
  `PreferenceEntity.firstLaunchCompleted = true`.
- Slide 1 "Drop gears so their teeth bite" · Slide 2 "Mesh a train to the
  power spindle" · Slide 3 "Light every target, save your gears".

### 2.3 Main Menu — `design/menu.png`
**Purpose:** home scene and navigation hub.
- Full-bleed clockwork scene; `COGFALL` logo (gear glyph as the "O") in the top
  third with depth shadow and a slow driver gear behind it.
- **PLAY** on a large brass plate (subtitle "Campaign · Bay N unlocked") →
  resumes current campaign bay.
- Two rich circular art medallions with labels: **Conduit** (level map) and
  **Foundry** (achievements).
- Corner circular art buttons: **How to play** (top-left, replays onboarding),
  **Settings** gear (top-right).
- Bottom integrated **best-score rail**: best mechanism (stars), Overdrive high,
  lifetime gears meshed — rolling numbers.

### 2.4 The Conduit (Level Map) — `design/levelmap.png`
**Purpose:** campaign progression + Overdrive entry.
- Header: back button, "The Conduit", progress `completed / 24`.
- A winding brass conduit pipe threads **mechanism nodes**: completed (brass
  gear + stamped number + earned stars), **current** (glowing, "Resume"),
  locked (dark gear + padlock, dimmed) with mechanism names
  (Wind-Up Lark, Brass Orrery, Escapement Gate, Sunflower Rig, Tidal
  Regulator …). Tapping an unlocked node opens Gameplay for that bay.
- Bottom **Overdrive rail** (endless mode, shows high score) → launches
  Gameplay in endless mode.

### 2.5 Gameplay (Bay) — `design/gameplay.png`
**Purpose:** the drop-and-mesh scene. `SpriteView` hosting the single
`GameScene`; HUD, pause, results are SwiftUI overlays.
- **HUD (overlay):** Bay chip, centre score with live **spin multiplier**
  (rolling number), **Heat** meter (brass→rust), Pause button.
- **Bay:** framed brass housing with side rails & bolts, a mounting grid, empty
  **axles**, the glowing **power spindle**, meshed gear train with glow-links,
  a translucent **aim guide** column with a drop arrow, a ghost falling gear,
  and a lit **target lamp** ("Powered").
- **Tray (overlay):** the in-hand gear (size label), the **Next up** queue of
  upcoming gears, and the **Drop** button. Tap column to aim, Drop to release.
- Juice: haptics on mesh/jam/power, screen shake on jam, hit-flash, particle
  burst on mesh & mechanism-alive, score roll-up.

### 2.6 Pause — `design/pause.png`
**Purpose:** modal over the dimmed, blurred bay (`scene.isPaused = true`).
- Brass seal with pause glyph, "Paused", current bay name, a mini stat strip
  (Score / Gears / Powered time).
- Buttons: **Resume** (brass primary), **Restart bay**, **Quit to Conduit**
  (destructive tint). Every button acts.

### 2.7 Results — `design/results.png`
**Purpose:** end-of-bay summary (win variant shown; a jammed/game-over variant
reuses the layout with "Mechanism jammed", 0 stars, and a **Retry** primary).
- Brass seal with the mechanism's fixture, radiant rays, "Bay N complete",
  headline, earned **stars**.
- Breakdown card: Powered-for time, Gears used `n / max`, Spare-gear bonus,
  **Total score** (rolling). Persists a `RunRecord` + updates `MechanismLevel`.
- CTAs: **Next bay** (primary), **Replay**, **Conduit**.

### 2.8 The Foundry (Achievements) — `design/achievements.png`
**Purpose:** browse earned marques (achievements).
- Header "The Foundry"; summary strip: marques forged `n / 12`, lifetime gears
  meshed.
- 2-column grid of achievement medallions: **forged** (glowing brass badge +
  "Forged"), **in progress** (dark badge + progress bar `x / y`), **locked**
  (padlock). Names: First Bite, Clean Machine, Overdrive 30k, No Jam, Full
  Train, Master Wright … driven by `AchievementRecord`.

### 2.9 Settings — `design/settings.png`
**Purpose:** minimal offline settings.
- Panel with exactly three actionable rows + a version footer:
  1. **Animation Intensity** toggle → `PreferenceEntity.animationsOn`
  2. **Haptics** toggle → `PreferenceEntity.hapticsOn`
  3. **Reset Progress** (destructive; confirmation alert) → wipes domain
     entities, re-seeds defaults, sets `firstLaunchCompleted = false`
     (returns to onboarding — never a black screen)
  4. **Version** text from `CFBundleShortVersionString`
- No Rate/Share/Contact/Privacy/Subscription/Sign-in/Notifications/Language/
  App-Icon/Social items.

---

## 3. Navigation flow

```
Splash ──▶ Onboarding (first launch only) ──▶ Main Menu
Main Menu ─ PLAY ───────────▶ Gameplay(currentBay) ─▶ Results ─▶ Next bay / Conduit
Main Menu ─ Conduit ────────▶ The Conduit ─ node ──▶ Gameplay(bay)
                                          ─ Overdrive ▶ Gameplay(endless) ─▶ Results
Main Menu ─ Foundry ────────▶ Achievements
Main Menu ─ Settings/⚙ ─────▶ Settings ─ Reset ▶ Onboarding
Gameplay ─ Pause ──────────▶ Pause overlay ─ Resume / Restart / Quit→Conduit
```

`-screenshotTour` auto-drives: Main Menu → Gameplay(demo) → Conduit →
Achievements → Settings, looping, 3 s per screen.

---

## 4. Core Data entities

Every entity has `id: UUID` and `createdAt: Date` (both mandatory).
`codeGenerationType="class"`. Every `@FetchRequest` declares `sortDescriptors`.
`viewContext.save()` after every mutation. The scene never touches Core Data;
the `GameViewModel` persists at game-over / checkpoint only.

### PreferenceEntity (singleton)
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| createdAt | Date | |
| hapticsOn | Bool | default true |
| animationsOn | Bool | default true |
| firstLaunchCompleted | Bool | default false — gates onboarding |

### MechanismLevel (one row per campaign bay, seeded on first launch)
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| createdAt | Date | |
| levelIndex | Int16 | 1…24, bay number |
| name | String | e.g. "Escapement Gate" |
| unlocked | Bool | bay 1 unlocked at seed |
| completed | Bool | |
| bestStars | Int16 | 0–3 |
| bestScore | Int32 | |
| fewestGearsUsed | Int16 | for the "Clean Machine" style bonus |
| lastPlayedAt | Date? | optional |

### RunRecord (one per finished session, both modes)
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| createdAt | Date | |
| mode | String | "campaign" \| "overdrive" |
| levelIndex | Int16 | bay number (0 for overdrive) |
| score | Int32 | |
| gearsMeshed | Int16 | |
| gearsSpare | Int16 | unused gears at solve |
| secondsPowered | Double | total time targets were driven |
| outcome | String | "solved" \| "jammed" |

### AchievementRecord (seeded catalogue, 12 rows)
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| createdAt | Date | |
| key | String | stable id, e.g. "first_bite" |
| title | String | "First Bite" |
| detail | String | one-line description |
| unlocked | Bool | |
| unlockedAt | Date? | optional |
| progress | Double | current toward target |
| target | Double | goal (e.g. 12 gears) |
| sortIndex | Int16 | display order |

### PlayerStats (singleton aggregate)
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| createdAt | Date | |
| totalGearsDropped | Int32 | |
| totalGearsMeshed | Int32 | shown on Menu & Foundry |
| totalMechanismsBuilt | Int32 | |
| bestOverdriveScore | Int32 | Overdrive high |
| longestPoweredStreak | Double | seconds |
| totalRuns | Int32 | |
| currentNoJamStreak | Int16 | feeds "No Jam" achievement |

---

## 5. Game architecture (SpriteKit specifics)

- **One** `SKScene` (`GameScene`) via `SpriteView`, created once in the
  `GameViewModel`; pause/resume through `scene.isPaused` in `onChange`.
- `PhysicsCategory.swift` — the only source of collision bitmasks
  (gear, axle, spindle, wall, target).
- `GameState` enum state machine: `menu · aiming · dropping · settling ·
  powered · paused · solved · jammedOut`.
- `GameViewModel: ObservableObject` publishes `score`, `spinMultiplier`,
  `heat`, `state`, `queue`, `starsEarned`; forwards intents (aim, drop,
  pause, restart).
- Fixed `zPosition` layers: background −100, gears/axles 0, particles/flash 50,
  HUD is a SwiftUI overlay (100 conceptually).
- Pure testable structs **outside** the scene: `ScoreEngine`, `MeshRules`
  (distance-based mesh test), `SpawnTable`, `DifficultyCurve`, `HeatModel`.
- Gears are pooled sprites recycled by size; no allocation in `update(_:)`.
- Settled gears pin to axles with fixed joints; the spindle drives rotation;
  mesh detection compares axle-centre distance to `r1 + r2 ± tolerance`.
