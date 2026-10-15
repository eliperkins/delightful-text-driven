# Slides App: Design Brainstorm

A single-purpose macOS 27 SwiftUI app that *is* the deck for "Delightful Text-Driven Experiences with SwiftUI's `TextRenderer`." One talk, one presenter, one Mac. Anything that only a general-purpose presentation tool needs is out of scope.

## Requirements

Eli's original requirements; everything below serves these.

- **Slide style:** content appears full screen.
- **External displays and speaker notes.**
- **Forward, back, and restart,** with hover UI for these.
- **No nav bar** (no title bar or toolbar chrome).
- **Arbitrary SwiftUI content** on slides when needed.
- **Target macOS 27.**
- **Follow the design sections of [speaking.io](https://speaking.io/design/typography/):** typography, color, transitions, and the rest. See [Design rules](#design-rules-from-speakingios-design-section).
- **Primitives as SwiftUI views,** e.g. `Slide { … }` and `TitleCard { … }`, modeled on how Keynote, PowerPoint, Deckset, and others structure slides. See [What existing tools teach us](#what-existing-tools-teach-us).
- **Single-purpose:** only for Eli, only for this talk. Cut corners judiciously. See [Corners cut on purpose](#corners-cut-on-purpose).

## Implementation decisions

Settled with Eli on 2026-10-01, before scaffolding. These override anything older in this doc.

| Topic | Decision |
|---|---|
| **Language** | Swift 6 language mode, with `MainActor` default isolation and approachable concurrency. |
| **Declaring slides** | A **result-builder DSL**: `Deck { Part(.hook) { OpeningTitle(); ManyWays().notes("…") } }`. See [Declaring slides](#declaring-slides). |
| **On-slide code** | `Snippets` reads the demo's own `.swift` file at runtime via `#filePath` and slices out `// slide:` regions. This works because the app only runs on this Mac, from this checkout. No bundle resources. |
| **Syntax highlighting** | swift-syntax (`SwiftParser` + `SwiftIDEUtils`): map `tree.classifications` to `Theme` code colors in an `AttributedString`, and treat capitalized identifiers as types. Read [Lustre](https://github.com/artemnovichkov/lustre) for tips; don't copy it. |
| **Code colors** | Derived from the palette's roles and contrast-checked on `codeBg`. See [Color roles](#color-roles). |
| **Palette** | **Lake, tuned only.** The Monarch palettes were dropped from the spec, and there's no runtime switcher. |
| **Header label** | Only where it orients the audience: the scorecards ("Text rendering", "SwiftUI text rendering"), every code split, slides with a legend in the bottom left, and "Lines, runs, and glyphs". Everything else has no header: a slide with a single statement (except "Lesson learned" on the subpixel quantization lesson), part cards (the big numeral already says which part), the history, the replicas, the intro, and the close. |
| **Header meta** | None on content slides: no part title and no slide counter. Only the Theme Gallery passes a meta. The title card puts the speaker's name under the subtitle instead. |
| **Presenter window** | Keynote-style: a timing strip on top; the current slide large on the left; the next slide and step dots on the right; notes below; controls at the bottom. |
| **Launch** | Both windows open as normal windows on the laptop, resumed at the last slide. **Present** (⌘⏎) moves the audience window to the projector and full screen. |
| **Full screen** | Native full screen on the external display. The borderless `.statusBar` window is the fallback, kept ready in the shim. |
| **Emphasis for renderers** | `SlideText.emphasized` marks `*emphasis*` runs with the `Emphasis` text attribute, because runs don't expose color. `Text(AttributedString)` drops custom attributes unless the view declares their scope, so any view whose renderer reads `Emphasis` applies `.attributedTextFormattingDefinition(SlideTextFormatting())`. |
| **Demo buttons** | Buttons inside live demos use `.buttonStyle(.demo)`. System button styles size themselves in window points and read tiny on the 1920-point canvas. |
| **Tests** | A Swift Testing unit target for logic only: navigation through steps and slides, jump-to-number, restart, persistence, snippet slicing, and highlighting classification. No UI or snapshot tests. |
| **First pass** | Build-order steps 1–2, then stop for review. |

---

## What existing tools teach us

| Tool | Building blocks | Builds / steps | Presenter | What to steal |
|---|---|---|---|---|
| **Keynote** | Theme → master slides (layouts) with placeholders (title, body, media, slide number) | Build in / out / action per object; Magic Move matches objects across slides | Presenter display items you can toggle and rearrange: Current Slide, Next Slide, Presenter Notes, Ready to Advance indicator, Clock, Timer (elapsed *or* remaining). Slideshow goes to the external display by default; **X** swaps displays; a number then Return jumps; Esc exits | Masters as a *small* set of layouts; builds consumed before advancing; the presenter display items; X to swap; jump-to-number; a remaining-time timer |
| **PowerPoint** | Slide master → layouts → placeholders; sections | Animation pane where each effect starts **On Click**, **With Previous**, or **After Previous**; Morph | Presenter view: notes, next slide, timer, zoom, pen | Sections group slides (maps to the outline's six parts). We only need **On Click**; anything that runs "with" or "after" is just a SwiftUI animation inside that step |
| **Deckset** | Markdown with `---` between slides; the *content shape* picks the layout (a lone heading is a title card, a bare image is full-bleed, `[.column]` splits) | `[.build-lists: true]` | `^` lines become presenter notes; presenter display on the other screen | Content-first primitives with almost no configuration; `[fit]` headings that scale to fill; notes live next to the slide |
| **SlideKit** (SwiftUI, open source) | `Slide` protocol (`@Slide` macro) that is just a `View`; `HeaderSlide`, `Item`, `Code` | `@Phase` enum of substeps per slide | Second window renders a live *copy* of the slide, plus a script and a stopwatch | Details below |
| **swift-dex** (SwiftUI) | `Slide` with `content` + `background`; `StandardLayoutSlide` with `head` + `body`; `Bullets`, `Code`, `Flipper`, video | Slides are stateless; an `@ActionContainerBuilder` lists `Apply(.fade, to: .element(0))`-style actions targeting views tagged with `.elementID` | Mirrors share slide-local state via `@SlideValue`, a `@State` replacement keyed by element ID and stored per slide, reset on back/jump | `@SlideValue` is the proven answer to "live demo in two windows" if we ever need it. Actions-by-ID is more machinery than a step number |
| **SlideUI** (SwiftUI) | Prezi-like plane of equal-size `Slide` types plus an ordered `[Focus]` camera path | Focus steps | A separate Control Panel window | Its README warns that when a button or text field holds first responder, forward/back keys stop working (an "Editing…" mode that needs Esc). Our input handling must not depend on focus |
| **present** (simonw, SwiftUI) | Every slide is a URL in a `WKWebView` | None | None; a tiny HTTP server (Network framework) serves a phone remote | A borderless `NSWindow` at `.statusBar` level, full screen, plus an `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` that swallows arrow keys before any view sees them. That monitor avoids SlideUI's focus problem |

**SlideKit, read at the source level:**
- It uses a fixed 1920×1080 logical canvas, scaled to the window with `scaleEffect(min(wScale, hScale))` and letterboxed.
- `forward()` advances the slide's phase first, then the slide. `back()` lands on the previous slide's *last* phase, like Keynote.
- The presentation window uses `.hiddenTitleBar` with its window buttons hidden, and the aspect ratio is locked in `windowWillResize`.
- Keys are menu `Commands` (→, return, ←), so they work no matter which view has focus.
- **The trap:** the presenter window renders a second live instance of the current slide. Live demos would run twice: double CPU, double audio from the podcast `AVPlayer`, and `@State` that diverges between windows. It would also skew our performance HUD. We should handle this explicitly (see "Live content in two windows" below).

**Patterns common to all of them:**
1. A fixed logical canvas, scaled to whatever display is attached.
2. A few layouts, not free-form positioning.
3. Builds are ordered steps inside a slide.
4. Notes are attached to the slide.
5. The presenter display shows current, next, notes, and time.
6. Key handling sits above the view hierarchy (menu commands or an event monitor), because a focused control inside a slide would otherwise swallow the clicker.

---

## Design rules (from speaking.io's design section)

| Guidance | What it becomes in the app |
|---|---|
| **Dimensions:** 16:9, 1920×1080 | One fixed canvas: `Theme.canvas = CGSize(1920, 1080)`. Everything is laid out in canvas points and scaled once at the root. |
| **Typography:** you can't go too big; strong contrast; fewer words; clean faces | The `SlideText` primitives in [Visual system](#visual-system): display at 128, statement at 132, and nothing under 30 on the 1080 canvas. System fonts only. |
| **Color:** a dark, a light, and one accent; shift color to mark sections; a drastic change signals the end | A dark ground, light ink, and one accent (Lake, tuned). Section cards flip to the light ground, which is the deck's one big color shift. See [Visual system](#visual-system). |
| **Transitions:** skip them | Slides change with a hard cut, and so do builds inside a slide. The talk's motion belongs in the *content* (the `TextRenderer` effects), never in slide chrome, which makes the effects stand out more. |
| **Duplicating objects:** keep repeated objects in exactly the same position so nothing jumps | Layout primitives own the positions (title baseline, margins, code frame), so a title sits in the same place on every slide. Builds use opacity instead of `if`, so revealing an item never reflows the others. A debug grid overlay helps check alignment. |
| **Images:** full-bleed; darken the photo or put a ~70% scrim behind text | `FullBleed(image or video, scrim:)` primitive. |
| **Scratchpad slide** | A `ThemeGallery` debug slide showing every primitive and token, kept out of the deck array but reachable in debug builds. |

---

## Visual system

The deck's look, converged over three rounds of mockups. Every slide is built from the primitives below and never sets a font, color, or position directly.

### Text primitives (`SlideText`)

Applied with one modifier, e.g. `.slideText(.display)`. Sizes are points on the 1920×1080 canvas.

| Primitive | Font | Sizes | Color role | Used for |
|---|---|---|---|---|
| `.display` | SF Pro, `.heavy`, `.width(.expanded)`, tracking −2.5% | 128 title, 124 section, 72 in demos | `ink`, emphasis in `accentText` | Title and section titles, live demo text |
| `.statement` | SF Pro, `.bold`, tracking −2% (serif stays on subtitles) | 132, 104 | `ink`, emphasis in `accentText`, `code` in SF Mono and `ink2` | Statements, transcripts |
| `.subtitle` | New York, `.medium` | 62, 54 | `ink2` | Under titles and section titles |
| `.label` | SF Pro, `.semibold`, `.width(.expanded)` | 40 | `accentText` | Header label (left) |
| `.meta` | SF Pro, `.medium` | 38 (the "Live" tag 30) | `muted` | Header meta (right), "Live" tag, legends |
| `.code` | SF Mono, line height 1.45 | 34 | code roles | Code panels |
| `.caption` | SF Mono | 30 | `muted` | Modifier captions, timecodes |
| `.numeral` | SF Pro, `.heavy`, no tracking (one glyph; negative tracking clips it) | 1000 | `shiftAccent` | Section card numeral |

Rules: no thin weights; no italics carrying meaning; nothing the room must read in `muted` below 34. System fonts cover Arabic, Hebrew, Devanagari, and CJK, so section 8 needs no bundled fonts.

### Layout constants

- **Margins:** 120 left and right on every slide.
- **Header:** `SlideHeader` at top 72, `HStack(alignment: .firstTextBaseline)` with label, spacer, meta. No rule. Only slides that pass a `label` show it (see "Header label" above).
- **Content top:** 190 for split and runs slides. **Bottom:** 110 for title and section stacks.
- **Split:** 58 : 42 with a 48 gap. Code sits on a `codeBg` panel with radius 14; the live pane has a 3-pt `line` border, a "Live" tag, and the modifier as a caption.
- **Section numeral:** right 70, bleeding 170 below the bottom edge.

### Color roles

`Theme` exposes roles, never raw palette colors. The deck uses one palette: **Lake, tuned**. (The Monarch alternates were dropped; they're still in the Deck System artifact.)

| Role | Lake, tuned |
|---|---|
| `bg` | `#1B1F27` (darkened for projectors) |
| `ink` | `#F4EEE2` (14.3:1) |
| `ink2` | `#D6BF9C` |
| `muted` | `#A7B4C2` |
| `accent` (fills) | `#3399CC` |
| `accentText` | `#86C8EC` (9.0:1) |
| `deep` / `onDeep` | `#2272A6` / `#F4EEE2` (4.5:1) |
| `future` | `#8A97A3` |
| `line` / `line2` | `#56637A` / `#7A8A9C` |
| `shiftBg` / `shiftInk` / `shiftAccent` | `#F4EEE2` / `#2D3A53` / `#456180` |
| `codeBg` | `#13161C` |

Lake's camel and tan are lightened from the original palette (`#D2C5AC`, `#BA9E7F`); `accentText` and `deep` are lifted and darkened Plumbague.

**Code colors** follow Xcode's split between SDK and project names, so code looks like the editor the audience knows. They are the one addition to Lake. Each is contrast-checked on `codeBg`:

| Code role | Color | On `codeBg` |
|---|---|---|
| keywords, `@Test`, `#Preview` | pink `#F28DB7` | 6.7:1 |
| SDK types | `#B9B8F9` (a tint of `runtimeIssue`) | 8.2:1 |
| SDK members and their argument labels | `#9997F6` (a tint of `runtimeIssue`) | 5.9:1 |
| project types | `#A5DAB7` (a tint of `live`) | 9.6:1 |
| project members and their argument labels | `live` `#6CC28A` | 7.0:1 |
| numbers | gold `#F0C05A` | 8.9:1 |
| strings | `ink2` | 8.5:1 |
| comments | `muted` | 7.2:1 |
| locals, parameters | `ink` | 11.5:1 |

Slides have only syntax, not Xcode's index, so `SwiftHighlighter` lists the project's types and members. Add a name there when a new snippet uses one.

### Motion

Slide chrome never moves: no transitions, no animated titles, hard cuts between slides and for builds. Motion appears only in demo content: the `TextRenderer` effects and the transcripts.

### Transcript current word

Two styles, both in the deck, as a `HighlightStyle` on the renderer:

- **`.deepPill`:** the current word in `onDeep` on a `deep` fill; past words `ink`, upcoming words `future`.
- **`.spotlight`:** no marker; the current word in `ink`, past words at 55% ink, upcoming words `future`.

A "one value, two looks" split slide in the podcast section flips `style:` live to show that changing one renderer property restyles every word. Dark text on a bright pill was rejected: on a dark slide it reads as a cutout.

### Design decisions and why

Each slide type came from three rounds of mockups.

| Slide | Decision | Origin |
|---|---|---|
| **Title card** | Expanded heavy title over a serif subtitle, bottom-aligned. The heavy/light rhythm comes from Swiss Proof. | Converged (round 2). Broadsheet's margin split was liked, but it risks looking awkward with wide type. |
| **Section card** | The light "shift" ground with an expanded title and a giant offset part numeral bleeding off the bottom right. | Proof (round 2), from Swiss Proof's offset "3". |
| **Statement** | A bold SF Pro statement under the Expanded header (accent label left, meta right, no rule). | Broadsheet's statement with Expanded's header. |
| **Split** | Code panel (58) beside a bordered live pane (42), with a "Live" tag and the modifier as a caption. | Expanded (round 2); round 1 directions 1, 2, 4, 5, 7 all had good splits. |
| **Runs diagram** | Glyph Inspector's dissection of a line into runs and glyphs. **Only** in the runs section, never as a general statement style. | Glyph Inspector (round 1). |
| **Transcript, player** | Karaoke-style transcript with no letterbox bars. Used for the podcast deep dive (section 11). | Subtitles (round 1), refined in round 3. |
| **Transcript, focus** | A single centered line showing how the animation is built. Used **once**, early (intro or API explainer). | Round 3. |
| **Current word** | `.deepPill` and `.spotlight` (above), plus the live style swap. | Round 3, after the contrast iterations. |

**Kept from the round 1 directions:**
- Swiss Proof's offset numeral and its title/subtitle rhythm.
- Margin Notes' classy, news-like feel, which suits Particle, but with heavier weights and stronger contrast.
- Kinetic's wide, WWDC-like expanded type, but without its animations.

**Rejected, and why:**
- **Gridlines** (Swiss Proof): visual noise.
- **Source File and Marquee:** didn't work at all.
- **Color Field:** its statement card was fine, but the rest was too chaotic.
- **Animated chrome** (Kinetic): pretty, but distracting. speaking.io says to skip transitions.
- **Margin Notes' thin serif, muted text, and italics:** too risky for legibility on a projector.
- **Letterbox black bars on transcript slides.**
- **Current-word styles:**
  - dark text on a bright pill: reads as a cutout
  - the **Ring** and **Progress fill** variants

**Palettes:**
- **Lake Ponchatrain** leads for its contrast, with its tans lightened further.
- **Nothing Comes to Mind** (Monarch) was second, since its orange `#EA7751` is on brand for Eli and for Swift. It was mocked up as dark and light variants, then dropped on 2026-10-01 in favor of Lake only.
- **An Honest Opinion** was dropped.

Display fonts in the mockups were web stand-ins: Archivo Expanded → SF Pro Expanded, Newsreader → New York, Schibsted Grotesk → SF Pro, JetBrains Mono → SF Mono.

---

## Architecture

```
DeckApp (@main)
├─ Presentation (@Observable): slideIndex, step, timer start; persisted index
├─ Deck: the ordered slides, grouped by part
├─ Window "audience"
│   SlideCanvas (1920×1080, scaled, letterboxed)
│     └─ current slide, .id(slideIndex) so each slide starts with fresh state
│   overlays (outside the scaled canvas):
│     hover controls · performance HUD · debug grid
└─ Window "presenter"
    current slide (thumbnail mode) · next slide (thumbnail) · notes
    clock · elapsed · pacing against part budgets · the same controls
```

### Declaring slides

Each slide is a small `View` struct. The deck is written with a result builder, and steps and notes are attached at the call site. `.steps(_:)` and `.notes(_:)` are methods on `SlideEntry`, **not** view modifiers. They return metadata, so the presenter can read the *next* slide's notes without rendering it.

```swift
struct MeetTextRenderer: View {
    @Environment(\.slideStep) private var step

    var body: some View {
        Slide("Meet TextRenderer") {
            Split {
                CodeBlock(Snippets.meetRenderer, focus: step == 0 ? 1...3 : 4...9)
            } trailing: {
                DemoStage { Text("Hello, world").textRenderer(StripedRenderer()) }
                    .build(at: 2)
            }
        }
    }
}

let deck = Deck {
    Part(.hook) {
        OpeningTitle()
        ManyWays()
        NotStatic()
        AboutMe()
    }
    Part(.foundations) {
        SectionCard()                       // reads its part from the environment
        MeetTextRenderer()
            .steps(3)
            .notes("""
            SwiftUI owns layout, you own drawing. One required method.
            """)
    }
    // …
}
```

- **How the builder works:**
  - `DeckBuilder.buildExpression` wraps any `View` in a `SlideEntry`: a type-erased view builder plus `steps` (default 1) and `notes` (default "").
  - `Part` collects its entries.
  - `Deck` flattens the parts into the ordered slide list, recording each slide's part.
- **Steps** are read from the environment: `@Environment(\.slideStep)`. The helper `.build(at: n)` sets opacity to 0 before step `n`, so layout stays stable. Navigation consumes steps before it moves to the next slide.
- **The part** comes from the grouping, so the section numeral and pacing budget follow automatically.
- **Each slide gets fresh state:** the canvas renders `AnyView(slide).id(index)`, so every live demo starts from its initial state when you arrive on it.

### Primitives

This is the equivalent of a small set of Keynote masters, sized to what the outline needs.

| Primitive | Use | Outline sections |
|---|---|---|
| `Slide(_ title:) { }` | Base layout: optional title at a fixed baseline, content area inside safe margins | Most slides |
| `SlideHeader(label, meta)` | Accent label left, optional muted meta right. Only on scorecards, code splits, legend slides, and the runs diagram | Those slides |
| `TitleCard(title, subtitle)` | Expanded display title over a serif subtitle, bottom-left, with the speaker's avatar, name, and event below. No header. | Opening, 16 |
| `SectionCard()` | Part divider (its part comes from the deck grouping) on the shifted ground, with the bleeding numeral | Between parts |
| `Statement("…")` | One sentence in the bold statement style, vertically centered. No header | 2, 13, 14 |
| `Bullets { Item… }` | Sparingly; each item can build in | 4 scorecard, 13 |
| `CodeBlock(snippet, focus:)` | Syntax-colored code; lines outside `focus` are dimmed | 6–12 |
| `Split { } trailing: { }` | Code on one side, the live result on the other | 6–10 |
| `DemoStage { }` | Full-bleed live SwiftUI content, with an optional controls panel | 7, 8, 11, 12 |
| `FullBleed(.video/.image, scrim:)` | Montage clips and Particle "before" footage; loops, autoplays, muted by default | 1, 2, 5, 14 |
| `Scorecard(label:marks:buildsIn:)` | The four ingredients as large titles; `marks` adds a solved or sealed-off icon to each row | 4, 5 |
| `PerformanceHUD` | Window overlay, toggled with a key | 12 |
| `RunsDiagram` | Special: a sentence in `.runsDiagram` (104, medium, so a bold word stands out) whose real lines, runs, and glyphs a `TextRenderer` outlines, one layer per step. Lives in `Talk/Foundations/`, built with section 7. Only in the runs section | 7 |
| `TranscriptSlide(.focus)` | Special: one statement whose words light up in time, timecode in the header, progress edge at the bottom. Used once, early, to show these animations can be built | 2 or 6 |
| `TranscriptSlide(.player)` | Special: current line plus blurred neighbor lines, with play, timecodes, and a scrub track. The deep-dive demo | 11 |

**Code that can't drift from the demo:** each demo file records its own path with `#filePath`. At runtime, `Snippets` reads that file from the checkout and slices out the regions between `// slide: meetRenderer` and `// slide: end`. The code on screen is then literally the code running next to it, with no build phase, script, or macro. *Cutting corners:* this only works on the Mac that built the app, which is the only Mac it runs on. `CodeBlock` highlights the code with the swift-syntax classifier (see [Implementation decisions](#implementation-decisions)).

**Plain SwiftUI for slide chrome:** `CodeBlock` dims unfocused lines with one `Text` per line and `.opacity`, and statements style code spans through `AttributedString`. `TextRenderer` is for the demos, not for styling the deck's own text.

### Windows and displays

- **Audience window:**
  - `Window(id: "audience")` with `.windowStyle(.hiddenTitleBar)`, `.toolbar(removing: .title)`, `.toolbarBackgroundVisibility(.hidden, for: .windowToolbar)`, `.windowToolbarFullScreenVisibility(.hidden)`, and `.persistentSystemOverlays(.hidden)`.
  - The result is no nav bar and no chrome, only the canvas on black.
- **Presenter window:** a second `Window(id: "presenter")`, opened with `openWindow`.
- **Getting onto the projector:**
  - SwiftUI's `defaultWindowPlacement` context only exposes `defaultDisplay` on macOS. I checked the macOS 27 SDK: there's no list of displays. So we need a small AppKit shim.
  - A `WindowAccessor` grabs each `NSWindow`.
  - A **Present** command (⌘⏎) moves the audience window to the first `NSScreen` that isn't the built-in display, then puts it into full screen. The presenter window goes full screen on the laptop.
  - With a single display, the same command puts only the audience window into full screen (rehearsal mode).
  - *Cutting corners:* no hot-plug handling. If a cable is reconnected, press Present again.
  - **Full screen:** native full screen depends on "Displays have separate Spaces" (on by default); with it off, full screen on one display blanks the other. The fallback is what `present` does: skip native full screen and size a borderless window to the screen's frame at `.statusBar` level. That's a small change inside the shim, so try native full screen first and keep the fallback ready.
- **Stage hygiene:**
  - While presenting, hold `ProcessInfo.beginActivity(options: .idleDisplaySleepDisabled)`.
  - Hide the cursor when idle with `NSCursor.setHiddenUntilMouseMoves`.

### Live content in two windows

SlideKit's approach would duplicate every live demo. Instead, pass an environment value `\.slideRenderMode` (`.live` or `.thumbnail`):
- The audience window renders `.live`.
- The presenter window renders both the current and next slides as `.thumbnail`.
- Demos check the mode: in `.thumbnail`, they show a static frame (no `TimelineView`, no `AVPlayer`, no repeating animations).

The upshot:
- Audio plays once.
- The HUD measures only the real slide.
- Nothing runs twice.

You interact with live demos on the projector screen with the pointer, which is what Keynote users do with embedded content anyway.

*Deferred unless needed:* shared demo state so the presenter window could drive the audience window's sliders and scrubber. If we need it, copy swift-dex's `@SlideValue`: a `@State` replacement that keys the value in a per-slide store on `Presentation`, so both windows read and write the same value. That's about 40 lines, and adopting it would change only the demos that use it.

### Navigation and input

| Input | Action |
|---|---|
| → ↓ Space PageDown Return | Forward: next step, then next slide |
| ← ↑ PageUp | Back: previous step, then the previous slide's *last* step |
| Type a number, then Return | Jump to that slide (Keynote style) |
| ⌘⇧R, or hover Restart (click twice) | Restart: slide 1, step 0, reset the timer |
| B | Black screen (Keynote's pause) |
| X | Swap which display gets the audience window (Keynote's shortcut) |
| H | Toggle the performance HUD. Debug overlays live in the Debug menu (⌃⌘T / ⌃⌘G / ⌃⌘B) so plain letter keys stay free for demos |

- **Keys go through one `NSEvent` local key-down monitor** (the approach `present` uses), installed at launch. It handles navigation keys before any view sees them, so a focused slider or button in a demo can't swallow the clicker, which is the failure SlideUI documents. It passes events through only when a text field is being edited, and every other key reaches the demos. Menu `Commands` still exist for discoverability (Present, Swap Displays, Export Stills, Export PDF) but aren't the navigation path.
- **Hover UI:**
  - In the audience window, `onContinuousHover` in the bottom band shows a Liquid Glass capsule (`.glassEffect()`) with ◀ · `12 / 48` · ▶ · ↺.
  - It fades out after ~2 s without movement and sits outside the scaled canvas, so it's crisp and never covers content during a PDF or PNG export.
  - The presenter window shows the same controls all the time.
- **Resilience:** `slideIndex` and `step` are persisted with `@AppStorage`, so a crash or relaunch mid-talk resumes on the same slide.

### Presenter window

- **Current and next slide** thumbnails; next shows step 0, or the next *step* if one remains.
- **Notes** in large type (~28 pt), with markdown allowed.
- **Wall clock and a timer** that shows time *remaining* in the slot (Keynote offers elapsed or remaining, and remaining suits a strict clock), plus **pacing**: each part carries its budget from the outline (Hook 6, Why hard 5.5, Foundations 9.5, Life 4.5, Advanced 11, Takeaways 5.5). The window shows planned versus actual time at each part boundary. With a strict ~42 min in a 40–45 slot, this may be the single most useful feature.
- **Step dots** for the current slide.

### Development ergonomics

- `#Preview` for each slide through a `SlidePreview(step:)` wrapper that renders at canvas size.
- Launch argument `-slide 17` to open straight onto a slide.
- A **Debug** menu, in debug builds only, with toggles saved across launches:
  - **Theme Gallery** (⌃⌘T) swaps the talk for a scratchpad deck of type, color, layout-guide, and build pages. It keeps its own saved slide.
  - **Layout Guides** (⌃⌘G) draws `Theme.Layout`'s safe area and split columns over any slide.
  - **Reveal Hidden Builds** (⌃⌘B) shows not-yet-built content as faint ghosts.
- **Backup export:** the Slides menu's "Export Stills…" and "Export PDF…" commands (`DeckExport`) walk every slide and step through `ImageRenderer` in thumbnail mode, at twice the canvas size (3840×2160) so blurs and shaders stay sharp, into a folder of PNGs or a vector PDF with one page per step. If the laptop dies or the app misbehaves, either one runs on any machine. `ImageRenderer` can't draw an `NSView`, so `Recording` shows a bundled poster frame in thumbnail mode. Record video of the live demos separately; the outline already calls for recorded fallbacks.

---

## Corners cut on purpose

- No markdown or document model. Slides are Swift, and the deck is an array literal.
- No style protocols (SlideKit's `HeaderSlideStyle` and similar). `Theme` is an enum of constants.
- Only 16:9, one theme, one talk.
- No slide transitions. No slide sorter or light table; jump-to-number covers it. A thumbnail grid can come later using the same thumbnail mode.
- No iOS, no Swift package, no macro. One app target.
- No display hot-plug handling. Present is a manual command, and X swaps displays.
- No phone remote (`present` serves one over HTTP); use a hardware clicker.
- No action or element-ID system like swift-dex's. A slide reads its step number and decides what to show.
- No per-step notes at first: one notes string per slide. Upgrade to `[String]` only if a slide needs it.

---

## Risks to check early

- **Text crispness under `scaleEffect`.** On a 1080p projector the scale is about 1.0, but test on a Retina display and a 4K external display. Fallback: pass a `slideScale` through the environment and multiply font sizes, instead of scaling the rendered layer.
- **Script coverage for section 8:** a custom display face may not include Arabic, Hebrew, Devanagari, or CJK. Keep the demo text in the system font, whose fallbacks (SF Arabic, SF Hebrew, Kohinoor, Hiragino) cover those scripts, and use any custom face only for slide chrome.
- **Venue logistics:** confirm with the organizers that you can present from your own Mac, the projector resolution and aspect ratio, and an audio feed for the podcast demo.
- **Clicker keys:** confirm which keys your clicker sends (usually PageUp/PageDown, sometimes B or period for black).

---

## Suggested build order

1. Canvas, `Presentation`, navigation commands, audience window with no chrome, hover controls.
2. The `Deck` result builder (`Part`, `SlideEntry`, `.steps`/`.notes`), the step environment, `.build(at:)`, and `Theme` tokens with the `ThemeGallery`.
3. Presenter window: thumbnail mode, notes, timer, and pacing.
4. The Present command (AppKit shim for the external display) and the idle-sleep assertion.
5. Primitives: `SlideText`, `SlideHeader`, `TitleCard`, `SectionCard`, `Statement`, `Split`, `CodeBlock` with bundled snippets, then the specials (`TranscriptSlide`; `RunsDiagram` was built with section 7).
6. Stub every outline section as a slide containing just its title and notes, so the full run is clickable and can be timed.
7. Then the real content: renderers, demos, the HUD, video, and the export commands.

---

## Sources

- speaking.io design: [typography](https://speaking.io/design/typography/), [dimensions](https://speaking.io/design/dimensions/), [color](https://speaking.io/design/color/), [transitions](https://speaking.io/design/transitions/), [images](https://speaking.io/design/using-images/), [duplicating objects](https://speaking.io/design/duplicating-objects/)
- Keynote: [present on a separate display](https://support.apple.com/guide/keynote/present-on-a-separate-display-tana4da2681/mac), [rehearse / presenter display options](https://support.apple.com/en-my/guide/keynote/tan1cb6ca7a3/mac)
- PowerPoint: [animate text or objects](https://support.microsoft.com/en-us/office/add-animation-to-slides%E2%80%8B-7db07067-4d78-40b5-bc87-5ff4f5ff6ff7), [customize a slide master](https://support.microsoft.com/en-us/office/customize-a-slide-master-036d317b-3251-4237-8ddc-22f4668e2b56)
- Deckset: [formatting docs](https://docs.deckset.com/English.lproj/Formatting/01-headings.html)
- SwiftUI projects, read at the source level: [SlideKit](https://github.com/mtj0928/SlideKit), [swift-dex](https://github.com/hagmas/swift-dex), [SlideUI](https://github.com/mikolasstuchlik/SlideUI), [present](https://github.com/simonw/present)
- macOS 27 SDK (Xcode 27.0 beta 2): on macOS, `WindowPlacementContext` exposes only `defaultDisplay`, with no list of displays.
