# CogFall — Design Specification

**Theme:** a gravity-fed clockwork machine shop at night — oiled deep-teal
housings lit by warm brass. ONE dominant colour family (deep teal / oiled
metal) + ONE accent (brass amber); rust is a functional-only danger tone.
Extreme type weights (200 / 800), ~3× jumps between type-scale steps, an 8px
spacing scale. The generic defaults are explicitly banned: no Inter/Roboto,
no purple-indigo-on-white gradients, no rows of identical rounded cards.

Source of truth for tokens: `design-tokens.css` (project root, mirrored at
`design/handoff/project/styles/tokens.css`). Rendered screens: `design/*.png`.
Self-contained HTML sources: `design/html/*.html`.

---

## 1. Color palette (exact hex)

### Dominant — deep teal / oiled-metal dark
| Token | Hex | Role |
|---|---|---|
| `--color-abyss` | `#08191C` | deepest background well, vignette floor |
| `--color-bg` | `#0C2529` | primary app background |
| `--color-surface` | `#123138` | raised panel / card |
| `--color-surface-2` | `#17414A` | raised-2 / active row / tray |
| `--color-teal` | `#1C6E74` | structural brand teal (rails, conduit pipe) |
| `--color-teal-deep` | `#124A50` | teal shadow / conduit core |

### Accent — brass amber (the ONE accent)
| Token | Hex | Role |
|---|---|---|
| `--color-brass` | `#F2A93B` | primary accent — CTAs, live gears, labels |
| `--color-brass-hi` | `#FFCE7A` | brass highlight / bevel light / icon strokes |
| `--color-brass-deep` | `#B9761E` | brass shadow |
| `--color-brass-edge` | `#7A4B12` | engraved edge / stamped rim / plate border |
| `--color-power` | `#FFD27A` | "mechanism alive" glow (stays in brass family) |

### Functional-only
| Token | Hex | Role |
|---|---|---|
| `--color-rust` | `#C4502E` | Heat meter, jam, destructive actions, Overdrive |
| `--color-rust-deep` | `#7C2E19` | rust shadow |

### Text on dark
| Token | Hex | Role |
|---|---|---|
| `--color-text` | `#F4E9D6` | warm cream — primary |
| `--color-text-2` | `#93B2B6` | cool steel — secondary |
| `--color-text-3` | `#5E7B80` | muted / captions |
| `--color-hairline` | `rgba(244,233,214,0.10)` | 1px dividers, card borders |

**Gear materials (SVG radial gradients):** brass
`#FFE7B4 → #F2A93B → #B9761E → #6E430E`; steel
`#D4E8EA → #7C9EA3 → #274A50`; dark/ambient `#255057 → #0C282D`.

---

## 2. Typography

No Inter/Roboto. Engraved-brass character from macOS system faces; extremes
only (200 / 800) with ~3× jumps in the scale.

| Family token | Stack | Use |
|---|---|---|
| `--font-display` | **Futura**, "Century Gothic", "Avenir Next", sans-serif | logo, titles, scores, counters |
| `--font-body` | **Avenir Next**, "Avenir", -apple-system, sans-serif | body copy, descriptions |
| `--font-plate` | **Copperplate**, "Copperplate Gothic Bold", "Futura", serif | engraved uppercase labels / eyebrows |
| `--font-num` | **Futura**, "DIN Alternate", "Avenir Next" | HUD counters (tabular feel) |

**Weights:** `--weight-thin: 200`, `--weight-book: 400`, `--weight-med: 600`,
`--weight-black: 800`. Titles and numbers use 800; body 400; secondary 600.

**Type scale (~3× jumps):**
| Token | Size | Usage |
|---|---|---|
| `--fs-eyebrow` | 12px | Copperplate plate labels, uppercase, `letter-spacing .2–.3em` |
| `--fs-body` | 15px | body copy |
| `--fs-title` | 22px | section titles (menu medallion, headers) |
| `--fs-display` | 40px | screen headers, PLAY, "Paused" |
| `--fs-hero` | 72px | logo / hero counters (~3× display, ~5× body) |

In-app iOS mapping: SwiftUI should register/approximate these with
`.system(size:weight:)` at the pixel sizes above; the display family maps to a
strong geometric face and plate labels are tracked uppercase.

---

## 3. Component language

- **PLAY / primary plate:** brass linear gradient
  `#FFDC8E → #F2A93B → #C9861F`, 1px `--brass-edge` border, top inner white
  bevel + bottom inner brass-deep bevel, brass drop-glow shadow; engraved
  dark-brown label (`#3A2408`) with a subtle top white text-shadow. Pressed =
  scale 0.96 + haptic.
- **Cards / panels:** teal glass `rgba(23,65,74,.6) → rgba(11,32,36,.85)`,
  1px hairline top edge, layered black shadow (depth). Never a flat fill.
- **Circular art medallions:** radial teal disc, brass ring border, inner
  emboss; hold a brass gear or thematic line-icon. Used for Conduit/Foundry
  and level-map nodes (rich art — never a plain SF-symbol circle row).
- **Gears:** 12-tooth SVG cog with spokes + dark hub; brass = live/interactive,
  steel = idle/neutral, dark = ambient background decor. Live gears carry a
  warm `--color-power` glow.
- **Toggles:** brass-gradient track when on (glow), steel knob when off.
- **Heat / danger:** rust gradient fills only; destructive buttons use rust
  border + `#FFB98C` label.
- **Backgrounds:** every screen gets a treatment — radial teal wash + warm
  bottom glow + faint ambient gears + film-grain overlay + inner vignette.
  No flat single-colour screens.

---

## 4. Per-screen layout

### Splash — `design/splash.png`
Centered three-gear cluster (brass large + steel + brass small) with a glowing
hub and small gear glyph; `COGFALL` wordmark in brass-gradient display; tracked
Copperplate tagline "The gravity machine shop"; a thin "mainspring" progress
bar near the bottom. **Mood:** the shop powering up in the dark. Zero logic.

### Onboarding — `design/onboarding.png`
Top: rounded **hero stage** (inset teal box) showing a ghost gear falling on a
dashed trajectory into a meshed brass/steel train beside a glowing power
spindle, with chips "Next gear" and "Power spindle · live". Below: glass **copy
card** (eyebrow "How it works · 1 of 3", 32px title with a brass emphasis word,
15px steel body). Progress **dots** (active = brass pill). Full-width brass
**Next** CTA. **Skip** top-right. **Mood:** a clear, inviting tutorial diorama.

### Main Menu — `design/menu.png`
Full-bleed clockwork scene; **logo** top third (gear as the "O") over a faint
slow driver gear, tagline pill. Large brass **PLAY** plate (subtitle + play
disc). Two circular art **medallions** — Conduit, Foundry — with plate labels.
Corner circular buttons: **?** (how-to) top-left, **⚙** settings top-right.
Bottom integrated **best rail**: Best mechanism (★), Overdrive high, Gears
meshed. **Mood:** a premium machine-room title scene, not a menu list.

### The Conduit (Level Map) — `design/levelmap.png`
Header (back, "The Conduit", `6 / 24`). A winding **brass conduit pipe**
(teal core + dashed brass centreline) threads **mechanism nodes**: completed
(brass gear, stamped number badge, earned stars), **current** (larger, brass
glow, "Resume" pill), locked (dark gear, padlock, dimmed) each with a
Copperplate name. Bottom **Overdrive rail** (rust-tinted, lightning mark, high
score, "Run"). **Mood:** a mechanical progress spine you climb.

### Gameplay (Bay) — `design/gameplay.png`
**HUD** row: Bay chip · centred score + "×2.4 spin" · Heat meter · Pause.
**Bay:** brass-railed housing with corner bolts, mounting grid, empty axles, a
glowing **power spindle** (chip "Power spindle"), a meshed **gear train** with
glow-links climbing to a lit **target lamp** ("Powered"), a translucent **aim
guide** column + drop arrow, and a ghost falling gear. **Tray:** in-hand gear
disc (size "L") · **Next up** queue of 3 · brass **Drop** button.
**Mood:** tactile, legible, physical — the heart of the game.

### Pause — `design/pause.png`
Dimmed, blurred bay behind a dark scrim; centred glass **card**: brass seal
with pause glyph, "Paused", bay name, mini stat strip (Score/Gears/Powered).
Buttons: **Resume** (brass), **Restart bay** (ghost), **Quit to Conduit**
(rust). **Mood:** a calm hold on a running machine.

### Results — `design/results.png`
Radiant rays behind a brass **seal** carrying the mechanism's fixture; eyebrow
"Bay 07 complete", 36px headline "Escapement Gate ticks!", earned **stars**.
Breakdown **card** (Powered-for, Gears used, Spare-gear bonus, **Total score**).
CTAs: **Next bay** (brass), **Replay**, **Conduit**. Jam variant swaps in a
rust seal + **Retry**. **Mood:** a satisfying mechanical payoff.

### The Foundry (Achievements) — `design/achievements.png`
Header "The Foundry"; **summary strip** (marques forged 7/12, gears meshed).
2-column **grid** of medallions: forged (glowing brass badge + "Forged"), in
progress (dark badge + brass progress bar + `x / y`), locked (padlock).
**Mood:** a wall of stamped brass marques.

### Settings — `design/settings.png`
Header "Settings". One glass **panel** with three engraved rows —
**Animation Intensity** (toggle), **Haptics** (toggle), **Reset Progress**
(rust destructive) — plus a gear-marked **Version 1.0.0** footer. **Mood:** the
workbench: quiet, precise, four controls only.

---

## 5. Imagery inventory

Per the fallback rule, all imagery is **inline SVG** authored in each screen's
HTML (`design/html/*.html`) — there is no `design/handoff/project/uploads/`
raster set. Reusable motifs and their intended role:

| Motif (inline SVG) | Where | Role |
|---|---|---|
| `#cog` 12-tooth gear symbol (brass / steel / dark gradient fills) | every screen | hero clusters, gameplay train, medallion & node icons, ambient decor, logo "O", version mark |
| Glowing **power-spindle** dot (radial `--color-power` + halo) | onboarding, gameplay | marks the always-driving anchor |
| **Aim-guide** column + drop arrow | gameplay | shows the drop lane |
| **Glow-link** bars | gameplay | visualise meshed connections |
| **Target lamp / bulb** (radial brass) | gameplay | lights when powered |
| **Conduit pipe** path (teal stroke + dashed brass centreline) | level map | connects mechanism nodes |
| **Radiant rays** starburst | results | celebration backdrop |
| **Mechanism fixtures** (lark, orrery, sun line-glyphs) | results, level-map nodes | per-bay identity |
| **Achievement line-icons** (mesh, star, bolt, spiral, plus) | foundry | one per marque |
| **Grain** dot-texture + **vignette** inner shadow | every screen | premium surface treatment (applied at 5% / heavy inner shadow) |

When the flux/native asset phase runs later, these motifs map 1:1 to PNG
assets: `bg_<screen>` backgrounds, `hero_*` gear clusters, `icon_*` line-icons,
`decor_*` ambient gears, `achievement_*` marques — following this palette and
typography.

---

## 6. Motion (design intent for the SwiftUI/SpriteKit phase)

- Splash: gears counter-rotate in, hub pulses; mainspring bar fills once.
- Menu: driver gear rotates slowly (~22 s), PLAY glow breathes, rolling stats.
- Gameplay: gears physically fall & settle; mesh = particle burst + brass flash
  + haptic; power reaching a target = lamp bloom + score roll-up; jam = screen
  shake + rust flash + heat rise.
- Results: stars stamp in one-by-one; total score rolls up.
- All decorative motion is gated on `PreferenceEntity.animationsOn`; button
  press-scale and haptics are interaction feedback and remain.
