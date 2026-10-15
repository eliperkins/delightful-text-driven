# Delightful Text-Driven Experiences with SwiftUI's `TextRenderer`

A conference talk by Eli Perkins (Particle), plus the macOS SwiftUI app that *is* the slide deck. The app runs every `TextRenderer` example live on stage.

## Files

- `README.md`: the abstract and the link to the slides. Hard constraints for the talk: a strict time limit with no running over, optional Q&A in the last ~10 minutes, and assume the audience knows nothing about the topic.
- `outline.md`: the talk in 22 sections across six parts, about 43 minutes, in the deck's order. Each section has a time budget, in-section "lesson learned" callouts, a table of where outside sources are used, and open items. **This is the source of truth for content.**
- `app-design.md`: the slides app's design. **Read it before any app work.** It covers:
  - research on Keynote, PowerPoint, Deckset, and SwiftUI deck frameworks
  - the **Visual system** spec: text styles, layout constants, color roles, motion, transcript styles
  - the **Implementation decisions** table (settled choices that override older text), the architecture (the `Deck` result builder, steps, windows, external display, presenter view)
  - navigation and input, corners cut on purpose, risks, and the build order

- `DelightfulTextDriven/`: the Xcode project (`DelightfulTextDriven.xcodeproj`, a macOS app target and a Swift Testing target; sources in `DelightfulTextDriven/DelightfulTextDriven/`). Build-order steps 1–4 are done: the deck DSL, navigation, the audience window, hover controls, `Theme`/`SlideText`, `.build(at:)`, the presenter window (⌥⌘P: thumbnails in `.thumbnail` render mode, notes, slot countdown, part pacing), Export Stills… and Export PDF… in the Slides menu (`DeckExport`: every step, in `.thumbnail` mode, as PNGs or a vector PDF, for a backup that runs without the app; `writeStills(to:slides:)` takes an optional slide filter, which `DelightfulTextDrivenTests/SlideCapture.swift` also uses — see "Check work" below), the Present command (⌘⏎: `Stage` moves the windows to their displays, full screen, no display sleep; X swaps displays while presenting), the layout primitives in `Primitives/` (`Slide`/`SlideHeader`, `TitleCard`, `SectionCard`, `Statement`, `Split`, `CodeBlock`; also on Theme Gallery pages), slide code cut from the app's own sources (`Snippets` reads `// slide: name` … `// slide: end` regions; `SwiftHighlighter` colors them with swift-syntax 604), and a **Debug** menu (debug builds only) with toggles for Theme Gallery (⌃⌘T), Layout Guides (⌃⌘G), and Reveal Hidden Builds (⌃⌘B). Step 6 is done too: `Talk/Talk.swift` has the title card, a section card per part, and for every outline section a title placeholder followed by large `Statement` slides for its findings and lessons (`code` spans render in SF Mono). Step 7, the real content, is in progress one section at a time in `Talk/<Part>/`: sections 6 ("Meet TextRenderer"), 7 ("Lines, runs, and glyphs": the `RunsDiagram` layout inspector, the `Highlight` attribute, and the strikethrough), and 8 ("Every language, for free": "Hello, world" in five scripts with glyph character indices, and the strikethrough that asks the run for its direction), and 9 in `Talk/Life/` ("Let SwiftUI animate it": the animated strikethrough, the wave, and the `TextReveal` title transition, which `TitleCard(revealStep:)` uses) are built, and so is 10 in `Talk/Advanced/` ("Renderers driven by your own values": a slider, a `TimelineView`, and a water distortion shader in `Water.metal` drive one text, and the `WordTime` attribute carries each word's time range). Section 11 ("Time travel") is built too: `TranscriptSlide` plays `clip.m4a` with Particle's `clip.json` transcript format through `PlayerClock` (a `TimelineView(.animation)` reads the `AVPlayer`'s current time every frame; a 15 Hz periodic observer made the scroll stutter), and `TranscriptRenderer` draws the current word, line blur, and scroll as a pure function of time. The slide's header credits the clip (`ClipAttribution`: the show's artwork next to a `SlideHeader`, podcast leading, episode trailing; speakers are in the notes, not on the slide) — Particle's podcast tools have no artwork URL, so the image comes from Apple's `itunes.apple.com/lookup?id=…` by the show's iTunes ID, saved as `clip-artwork.jpg` next to the clip. `PARTICLE_API_KEY=… swift scripts/make-clip.swift <clip ID> [seconds]` makes the clip from a Particle podcast clip (`particle_podcast_list_clips` in the Particle MCP finds IDs): it cuts the clip's audio and takes word times from `GET /v1/podcasts/episodes/{id}/transcript/words`, the only endpoint that times single words. `Talk/Advanced/Clip/` is gitignored, since the clip is copyrighted: without it, the slides show `Clip.missing`, which explains how to make one. Section 12 ("Tuning") is built: `StyleSwap` flips `HighlightStyle` live, and `TuningSlide` plays the clip next to controls for `TranscriptRenderer.Tuning` (blur, culling, per-glyph drawing). **H** toggles `PerformanceHUD` on the audience window: a stacked monospaced panel in the top-leading corner with the display refresh rate from a display link (not frames drawn), draws per second from the `Counted` wrapper renderer (it writes to the unobserved `DrawCounter`, and only in `.live` mode), and this process's CPU from `task_info` time deltas, like Activity Monitor. It has no GPU metric, and blur and compositing cost land in WindowServer, so blur's cost barely shows. Section 13 ("Use, don't abuse") is built in `Talk/Takeaways/`: `StrikeComparison` animates the built-in `.strikethrough` next to the `Strikethrough` renderer, `BuiltIns` shows `numericText` and a gradient with no renderer, and `Cascade` shows that a renderer cascades to every `Text` inside a container, that the closest renderer replaces the ones above it (they never combine), and that `Counted` combines effects by wrapping a base renderer. Section 14 ("Build delight") is built there too: `Replay` loops section 2's four effects in a 2×2 grid, then the through-line and the close. Sections 1–3 are built in `Talk/Hook/`: `Screens` (four iPhone screenshots from `Talk/Hook/Screens/`, status bars cropped) after the title card; one `Era` slide per step in the history of iOS text APIs, 2008 to 2022, with only versions checked against the SDK headers; four `Replica` slides for section 2 (`SpoilerRenderer`, `MarkerSweep`, `Focus`, `LyricFill`), with no captions, each around an effect view that loops itself with `Loop` and takes its text style; after the spoiler, a `Requirements` slide that builds in a PM's ticket one line per step; `Hello` (👋, then the name and handles, next to the `Headshot` asset); `AboutParticle` (the logotype, large); and two `Recording` slides, one per Particle screen recording (`Talk/Hook/Recordings/`: trimmed to the effect, cropped to its region, HEVC, no audio), which loop muted in `LoopingVideo` and show a bundled `-poster.jpg` frame in `.thumbnail` mode. Part 2 is built in `Talk/WhyHard/`: the `Scorecard` primitive shows the four ingredients (section 4 cuts in one per step; section 5 marks layout and change solved, positions and drawing sealed off), `OverlayStrike` runs Particle's pre-iOS 18 overlay strikethrough, and `SegmentedTranscript` plays the clip as three styled `Text` segments. Resources and Thanks (sections 15 and 16) are built; the Thanks slide uses vector template assets for the service icons and carries no Particle branding, since the talk isn't a Particle-sponsored talk. The shader needs the Metal Toolchain (`xcodebuild -downloadComponent MetalToolchain`). `Emphasis` marks `*emphasis*` runs for renderers; `Text(AttributedString)` keeps it only with `.attributedTextFormattingDefinition(SlideTextFormatting())`. A code span can't sit inside `*emphasis*` in `Statement`/`Takeaways` text — markdown drops the inner `code` intent, so it renders in the emphasis color/font instead of SF Mono; keep `` `code` `` outside the `*...*` span.
- `scripts/link-xcode-skills.sh`: links Apple's agent skills from inside the selected Xcode into `.claude/skills/` (see "Working in Xcode").

## Working in Xcode

The Xcode MCP server (`xcrun mcpbridge`) is connected, and Xcode must be running with the project open.

- **Target Eli's open Xcode window,** not a background copy:
  - Start with `XcodeListWorkspaces` and pass the `windowtab-…` identifier as `workspaceIdentifier`.
  - `XcodeOpenWorkspace` creates a separate background (headless) workspace with its own state. Ours had no active scheme, so builds against it failed with "No active scheme is selected".
  - Only open a workspace when no window has the project open, and close it with `XcodeCloseWorkspace` afterward.

- **Use the Xcode MCP tools instead of shell commands** for project questions:
  - `XcodeLS`, `XcodeGlob`, `XcodeGrep`, and `XcodeRead` take workspace-relative paths, not filesystem paths.
  - The project uses Xcode 27's JSON `project.xcproj` with a synchronized folder, so any file created under `DelightfulTextDriven/DelightfulTextDriven/` joins the app target automatically. There's no pbxproj to edit.
- **Check work, fastest first:**
  1. `XcodeRefreshCodeIssuesInFile` gives live diagnostics in seconds and catches made-up APIs and missing imports.
  2. `RunCodeSnippet` is a REPL in the context of a file, for trying ideas.
  3. `RenderPreview` checks how a slide looks.
  4. `BuildProject` is the full build, and slow.
  5. `TEST_RUNNER_CAPTURE_SLIDES=62,64-66 TEST_RUNNER_CAPTURE_DIR=<dir> xcodebuild test -project DelightfulTextDriven.xcodeproj -scheme DelightfulTextDriven -only-testing:'DelightfulTextDrivenTests/captureSlides()'` (from `DelightfulTextDriven/`) renders those slides of the real deck, every step, to `<dir>/NN-S.png`. It replaces `<dir>`. Normal test runs skip it.
  - If `xcodebuild test` fails with `Command CodeSign failed` on the built app's `.xctest` bundle ("code object is not signed at all"), a concurrent Xcode build left it unsigned. Delete just that `Contents/PlugIns/DelightfulTextDrivenTests.xctest` under the app in DerivedData (not the whole DerivedData folder) and rerun.
  6. After editing a `// slide: name` … `// slide: end` region, run `DelightfulTextDrivenTests/SnippetTests/slideCodeFitsTheCodePanel()`. `CodeBlock` uses `.fixedSize()`, so a snippet over 14 lines or 42 characters wide overflows the panel with no warning until you render it. This test catches both before a capture run.
- **Verify new APIs before using them.** The macOS 27 / SwiftUI 27 APIs (Liquid Glass, `@State` as a macro, window placement, etc.) are newer than training data. If an API isn't found in the project, assume it's new and look it up before guessing.
  - **Sosumi MCP first:**
    - `searchAppleDocumentation` and `fetchAppleDocumentation` return Apple docs and the HIG as Markdown.
    - `fetchAppleVideoTranscript` returns WWDC transcripts, e.g. `/videos/play/wwdc2024/10151` for the talk's TextRenderer source.
  - **The SDK interface files are the ground truth** for signatures, availability, and APIs too new for the web docs. Grep `$(xcrun --sdk macosx --show-sdk-path)/System/Library/Frameworks/SwiftUI.framework/Versions/A/Modules/SwiftUI.swiftmodule/arm64e-apple-macos.swiftinterface`.
    - Use `SwiftUICore.framework` for `glassEffect`, `Text.Layout`, and `TextRenderer`.
    - Example: the docs list `TextRenderer` as iOS 17 / macOS 14 (the protocol), but `.textRenderer(_:)` requires **iOS 18 / macOS 15**. Say iOS 18 in the talk.
  - Xcode's own `DocumentationSearch` MCP tool is disabled in this beta. There's no Settings toggle, and the hidden `IDEChat*MCPTools` defaults didn't enable it, so don't retry.
  - **For SF Symbols names and their OS availability,** read `/System/Library/CoreServices/CoreGlyphs.bundle/Contents/Resources/name_availability.plist` (`plutil -convert json -o -`), e.g. to find `laurel.leading`/`laurel.trailing` for award badges. Prefer a system symbol over a custom asset when one exists.
- **Apple's skills:**
  - `swiftui-specialist` and `swiftui-whats-new-27` are linked into `.claude/skills/`. They point through `/var/db/xcode_select_link`, so they follow `xcode-select -s`.
  - Run `scripts/link-xcode-skills.sh` after a fresh clone or an Xcode update, or pass other skill names to link more. The links are local: each linked skill folder has a `.gitignore` that ignores the folder.
  - Apple's bundled framework docs are in `/var/db/xcode_select_link/../PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation/`. The ones relevant here are `AppKit-Implementing-Liquid-Glass-Design.md`, `SwiftUI-Implementing-Liquid-Glass-Design.md`, `SwiftUI-Styled-Text-Editing.md`, and `Foundation-AttributedString-Updates.md`. Read them on demand.
- **Swift style** (Xcode's agent defaults):
  - 4-space indentation
  - `@State private var` for view state
  - async/await, never Combine
  - no force unwraps
  - the Testing framework for tests
- **Keep changes scoped** to what was asked.

## Ground rules

- **The talk is about `TextRenderer`.** Explain `Text.Layout`, lines, runs, and slices only as far as `draw(layout:in:)` needs them.
- **The slides app is a macOS app targeting macOS 27** (Xcode 27). Don't add availability checks or iOS support. It's single-purpose (one talk, one presenter), so cut corners where `app-design.md` says to; don't build a general presentation framework.
- **Outside sources are woven in but never cited on stage:** WWDC24 session 10151, fatbobman's TextRenderer article, and twostraws/Prismic. Never write "watch this", "read this", or "use this library" on a slide or in speaker notes. All links go on the **penultimate slide**. Keep Prismic's MIT license notice if its code is reused.
- **Particle's examples** (the strikethrough and the transcript renderer) are simplified macOS ports of Particle's iOS code. Port examples to macOS rather than demoing the iOS app.

## Visual system essentials

The full spec is in `app-design.md` → "Visual system". The essentials:

- **Canvas:** one fixed 1920×1080 canvas, scaled once at the root. All sizes are canvas points, and nothing renders under 30.
- **Fonts and colors through primitives only:** slides set fonts with `.slideText(...)` and colors with `Theme` roles, never raw fonts, hex values, or positions. The tokens live in `Theme/Theme.swift` (`Theme.Layout` and color roles) and `Theme/SlideText.swift`.
- **No arbitrary numbers:**
  - Slide content uses `Theme.Layout` and `SlideText`. If a value is missing, add a named token.
  - Window chrome (hover controls, the presenter UI) uses SwiftUI's defaults (`.padding()`, stack spacing, text styles) and natural sizing, not hand-picked padding or frames.
  - Durations are named constants. Previews use `SlidePreview`.
- **System fonts only:**
  - SF Pro Expanded heavy for display text
  - SF Pro bold for statements, with `code` spans in SF Mono
  - New York for subtitles
  - SF Pro for labels and meta text
  - SF Mono for code

  System fonts also give the RTL and non-Latin section full script coverage.
- **Palette:** Lake, tuned only. The one exception is code: it uses Xcode-like colors (pink keywords, purple SDK names, green project names; see `app-design.md` → "Code colors"). When a snippet uses a new project type or member, add it to `SwiftHighlighter.projectTypes` or `projectMembers`.
- **Contrast first:** no thin weights, no italics that carry meaning.
- **Slide chrome never moves.** Slides and builds change with hard cuts, and only demo content animates. Never animate a build.
- **Special slides** are each used only in their own section: `RunsDiagram` (runs section), `TranscriptSlide(.player)` (the podcast deep dive), and `TranscriptSlide(.focus)` (once, early).

## Working on content

- Outline sections stay at 2–3 sentences: high level with some technical detail. They're building blocks, not a script, with no verbatim lines.
- Keep the through-line intact: *Text doesn't need to be boring. Delight your users with the right flourish.*
- The time budget is tight (~42 of 40–45 min). When adding material, say what to trim. `outline.md` → "Open items" has the trim plan.
- Slide code is simplified, but it's the same code that runs in the demo (see "Code that can't drift from the demo" in `app-design.md`).
