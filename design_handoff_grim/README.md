# Handoff: grim — design recreation

## Overview

`grim` is a memento mori iOS app that surfaces, every time you open it, exactly how many days/weeks/years remain in your statistical life. The design package in this handoff covers every screen of the existing SwiftUI app at a level of fidelity sufficient to ship — onboarding, the main countdown, the week strip, the life list (with its Anthropic-powered "today" prompt), per-day detail, settings, and a 4,680-week life-grid visualization.

## About the design files

The HTML/JSX files bundled here are **design references created in HTML, not production code**. They are React prototypes built to demonstrate the intended look, motion, and interaction patterns. The target codebase is the existing SwiftUI app at https://github.com/jeremiahleung-dev/grim — your job is to **recreate these designs faithfully in SwiftUI**, using the existing `Theme.swift` tokens, `UserData` store, and view structure already established in that repo. Do not port the React code directly.

Most of the screens already exist in the Swift source (`ContentView`, `OnboardingView`, `LifeListView`, `DayDetailView`, `SettingsView`, `CountdownView`); the design refines spacing, the wheel-picker treatment, the daily-prompt card, and adds the interactive 4,680-week grid as a new view.

## Fidelity

**High-fidelity.** All colors, typography, spacing, line counts, and copy are final and match `Theme.swift` exactly. Wheel pickers, sliders, sheet animations, and swipe-to-change-unit interactions are implemented end-to-end so behavior is unambiguous.

## Screens / views

### 1. Onboarding · Welcome (`OnboardingView` step 0)
- **Layout**: full-bleed `Theme.background`. Content left-aligned in a vertical stack with 28pt horizontal padding, vertically centered.
- **Components**:
  - `grim` wordmark — `fontDisplay` (40pt mono medium), color `ink`.
  - Body — `fontLabel` (11pt mono), color `muted`, lineSpacing 6, three lines: `you have a finite number\nof days.\n\nthis is how many remain.`
  - `tap to begin` — `fontLabel`, color `muted` opacity oscillating between 0.25 and 0.6 over 1.4s ease-in-out, autoreverses forever.
- **Interaction**: tap anywhere advances to step 1 with a light haptic.

### 2. Onboarding · DOB (`OnboardingView` step 1)
- Title "when were\nyou born?" — `fontDisplay`, lineSpacing 4.
- `DOBPickerView` — wheel-style `DatePicker` (`.wheel` style, dark color scheme, accent tint `#e8a045`, hidden labels, max date = today).
- CTA button at the bottom — `ink` background, `bg` text, 18pt vertical / 24pt horizontal padding, 28pt horizontal margin from edges. Label: "next" with `arrow.right` glyph.

### 3. Onboarding · Life expectancy (`OnboardingView` step 2)
- Title "how long\nwill you live?" — `fontDisplay`.
- Big numeric readout — `fontHero` (72pt mono medium).
- `Slider` 70…120, step 1, `Theme.accent` tint.
- "70" / "120" min/max labels in `fontLabel` `muted`.
- CTA "start" with `arrow.right`. On submit: persist `dateOfBirth` and `lifeExpectancy` to `UserData`, set `hasOnboarded = true`.

### 4. Main · Countdown (`ContentView`)
- **Top chrome**: `padding-top: 60`, horizontal 28. `grim` label (`fontLabel` `muted`) on the left; ellipsis button on the right (opens settings sheet).
- **Week strip** (`WeekStripView`): under the header, 28pt horizontal padding, 7 equal-flex columns. Each column: single-letter weekday (`S M T W R F S` — Thursday is `R`, intentionally) and a 3pt circular dot marking days that have tasks. Today is `accent`, past days are `ink @ 0.2`, future days are `ink @ 0.6`.
- **Center** (truly centered on the screen, drag-offset on horizontal swipe):
  - Big number — `fontHero`, `ink`, `minimumScaleFactor: 0.4`, `numericText` content transition.
  - Unit label ("days remaining" / "weeks remaining" / "years remaining"), `fontLabel` `muted`.
  - Today's date (`weekday(.wide).month(.wide).day()`), `fontLabel` `muted @ 0.45`.
  - Three 4pt page-dots indicating current unit.
- **Bottom chrome**:
  - "today" prompt card — only shown when there's a daily prompt or the life list is non-empty. `Rectangle().stroke(Theme.border, 1)` with 18pt internal padding. Two stacked labels: `today` (muted) and the prompt text (`ink @ 0.8`, lineSpacing 4, lineLimit 2). Empty-state copy: "tap to add things you want to do with your days →" in `muted @ 0.5`.
  - Bottom hint button — `^` chevron + either "your life list" or "N things". `muted @ 0.4`. 48pt bottom padding.
- **Gestures**:
  - Horizontal drag on countdown: < -30 advances to next unit, > 30 to previous, with a spring-back to 0 offset. Light haptic on switch.
  - Vertical drag up > 50 anywhere on screen: opens life-list sheet.
  - Tap any week-strip day: opens that day's `DayDetailView` sheet.

### 5. Life list sheet (`LifeListView`)
- Bottom sheet with a 36×4 muted handle, "your life list" header label and `xmark` close.
- "today" card if list is non-empty: `Rectangle().stroke(border)`, 20pt padding. Shows the AI-generated prompt with a `refresh →` button (calls `AnthropicService.generateDailyPrompt`). Loading state: `ProgressView` + "thinking...".
- List rows: 4pt accent dot + item text in `fontLabel` `ink`, 28pt horizontal / 10pt vertical. Swipe-to-delete with destructive trash button.
- Bottom input: `Rectangle().stroke(border)` containing a placeholder "add something..." textfield + `+` button. Submit triggers light haptic, appends to `userData.lifeItems`, regenerates prompt.

### 6. Day detail sheet (`DayDetailView`)
- Header: handle + lowercase weekday/month/day + close.
- Prompt — `muted @ 0.5`:
  - today: "what will you do with today?"
  - past: "what did you do on <weekday>?"
  - future: "what will you do on <weekday>?"
- Empty state: "nothing yet." in `muted @ 0.3`.
- Task rows: same dot+text pattern as life list. Today's dots are `accent`, other days' dots are `muted`.
- Same input pattern as life list, calling `userData.addTask(_, for: date)`.

### 7. Settings sheet (`SettingsView`)
- Handle + "settings" header + close.
- Two sections, only the "active" one is at full opacity (others fade to 0.45). Tap to focus.
  - **date of birth** — `DOBPickerView` with 12pt internal horizontal padding.
  - **life expectancy** — `LifeExpectancyPicker` (same component as onboarding step 3).
- Save button at the bottom — `ink` bg, mirrors onboarding CTA. On press: success haptic, write to `UserData`, animate label to "saved" + checkmark with `accent` background for 0.8s, then dismiss.

### 8. Bonus · Week-of-life grid (refines `CountdownView`)
- New screen demonstrating `lifeExpectancy × 52` weeks as a grid.
- 52 columns, `1fr` each, `gap: 1.5`. Each cell `aspect-ratio: 1/1`, `borderRadius: 1`.
- Cell color:
  - past weeks: `muted @ 0.5`
  - current week: `accent`
  - future weeks: `surface`
- Centered vertically. Above the grid: `your life · in weeks` label and `<lived years>/<total>` counter. Below: hover/tap readout (`week N · age X.Y`), `<weeks remaining> weeks left`, and a legend (lived / this week / ahead).

## Interactions & behavior

| Where | Action | Result |
|---|---|---|
| Welcome screen | tap anywhere | advance, light haptic |
| Onboarding CTA | tap | advance step (or finish) |
| Countdown number | horizontal drag > 30 | switch unit, light haptic, spring-back |
| Week strip | tap day | open `DayDetailView` sheet |
| Today card / "N things" | tap | open `LifeListView` sheet |
| Anywhere on main | drag up > 50 | open `LifeListView` sheet |
| Ellipsis | tap | open `SettingsView` sheet |
| Life-list row | swipe trailing | delete (destructive), invalidates prompt |
| Add input | submit | append item, regenerate prompt |
| Refresh button | tap | regenerate prompt via Anthropic |
| Settings save | tap | success haptic, "saved" + checkmark for 0.8s, dismiss |

## State management

`UserData.shared` (already in repo) — `ObservableObject` backed by `UserDefaults(suiteName: "group.com.grim.app")`. Keys:

- `dob: Date`
- `lifeExpectancy: Int` (default 100)
- `displayUnit: DisplayUnit` (.days/.weeks/.years)
- `lifeItems: [LifeItem]` (JSON-encoded)
- `dailyPromptText: String?`
- `dailyPromptDate: Date?`
- `weekTasks: [String: [DayTask]]` (key = `yyyy-MM-dd`)

`@AppStorage("hasOnboarded", store: …)` — gates `RootView` between `OnboardingView` and `ContentView`.

The daily-prompt cache key is "today's date" — if `dailyPromptDate` is the same calendar day as now and `dailyPromptText` is non-empty, skip regeneration.

## Design tokens (`Theme.swift` — already in repo)

| Token | Value |
|---|---|
| `background` | `#0a0a0a` |
| `surface` | `#1a1a1a` |
| `ink` | `#f0ece0` |
| `muted` | `#888888` |
| `border` | `#2e2e2e` |
| `accent` | `#e8a045` |
| `fontHero` | system 72 medium monospaced |
| `fontDisplay` | system 40 medium monospaced |
| `fontMono` | system 22 medium monospaced |
| `fontLabel` | system 11 regular monospaced |

**Spacing**: 28pt horizontal screen gutter is the standard. 48pt bottom inset above the home indicator. Sheets use the same 28pt horizontal gutter; 12pt top + 24pt below the drag handle.

**Borders**: 1pt `Theme.border` strokes on rectangles for inputs and cards (no corner radius — `Rectangle()`, not `RoundedRectangle`).

**Copy convention**: lowercase everything in UI labels. Sentence-case is reserved for AI-generated prompt content.

## Assets

No raster images, icons, or fonts to ship — the app uses SF Symbols (`ellipsis`, `xmark`, `chevron.up`, `arrow.right`, `plus`, `trash`, `checkmark`) and the system monospaced font. The accent color `#e8a045` is the only brand asset.

## Anthropic integration (`AnthropicService.swift`)

The "today" prompt is generated by Claude Haiku 4.5. The system prompt and rules are already in the source — preserve them exactly:
- Model: `claude-haiku-4-5-20251001`
- max_tokens: 150
- System text uses `cache_control: ephemeral`
- API key is in `grim/Shared/Secrets.swift` (gitignored — must not be committed)

## Files in this bundle

- `grim — designs.html` — entry point; open in a browser to see all screens on a pan/zoom canvas.
- `screens.jsx` — every screen component, named to match the SwiftUI views.
- `app.jsx` — canvas layout (which artboards land in which section).
- `ios-frame.jsx` — iOS device chrome (status bar + home indicator).
- `design-canvas.jsx` — pan/zoom canvas wrapper.
