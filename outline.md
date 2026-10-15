# Delightful Text-Driven Experiences with SwiftUI's `TextRenderer`: Outline

**Format:** ~43 min talk + optional ~10 min Q&A · the slides are a macOS SwiftUI app, so the simplified slide code runs live on screen
**Audience assumption:** comfortable with SwiftUI, new to `TextRenderer`
**Through-line (repeat it for retention):** Text doesn't need to be boring. Delight your users with the right flourish.
**Outside examples:** effects and lessons from the WWDC24 session, fatbobman's article, and Prismic are woven in without citing them on stage. All links live on the penultimate slide (see [Where the outside examples show up](#where-the-outside-examples-show-up)).
**Shape:** six parts, named like WWDC chapters (`TalkPart` in `Deck.swift`; its budgets drive the presenter's pacing strip). Parts 3 and 4 tell each Particle feature as goal → try (the real "before") → refine.

> **Lesson learned** callouts carry hard-won lessons, placed in the section where they matter instead of collected at the end.

---

## Part 1: Lead in (~7 min)

### 1. So many ways to put text on screen (~2 min)

Open with the why, and deliberately overwhelm: after the title card and four text-heavy iPhone screens, a rapid-fire history of text on iOS, one hard-cut slide per era, from `UILabel` and `UIWebView` in iPhone OS 2 through Core Text, `attributedText`, TextKit, SwiftUI `Text`, TextKit 2, and `numericText` in iOS 16. Each slide is just the year and the API names; what each era changed lives in the notes. The timeline lands on "iOS never lacked ways to *display* text" and stops before iOS 18, so `TextRenderer` stays a reveal.

### 2. Text doesn't have to be static (~2 min)

Keep overwhelming, now with motion: four live replicas of text effects, each a challenge ("how would you build this?"). The spoiler comes first, then a PM's ticket builds in one requirement at a time (Dynamic Type, l10n and RTL, every screen size, VoiceOver) until the quick hacks are gone. Then a highlight that follows a phrase across a line wrap, a reading focus that sharpens one line, and a lyric that fills word by word. The slides show only the effect, with no captions. A centered "How?" holds for a 3-second pause, then `Makes` closes the section by naming what `TextRenderer` makes these effects.

### 3. Self intro (~1.5 min)

The intro comes after the why, per the organizer's advice: name and handles next to the headshot, then Particle and why text polish matters in an app where reading and listening are the product. Two Particle screen recordings (the onboarding strikethrough and the podcast clip transcript) show the effects ship. Pause and reset before the technical part.

### 4. Why animated text was hard (~1.5 min)

Re-ground with a question on its own slide: "Why is delightful text *still so hard*?" A scorecard cuts in four ingredients: **layout**, **positions** (where lines, words, and glyphs ended up), **drawing** (a way to draw each piece differently), and **values over time**. A second scorecard marks what SwiftUI `Text` solved (layout and change) and what it sealed off (positions and drawing), and the reveal follows: `TextRenderer` opens up *positions* and *drawing*.

## Part 2: Lines, runs, and glyphs (~9 min)

### 5. Meet `TextRenderer` (~2 min)

First, how you apply one: `Text("Hello, world").textRenderer(Wave())` on its own code block. `.textRenderer(_:)` reaches every `Text` inside it like a font, and the wave gets built in section 8. Then the whole protocol on one slide: `draw(layout:in:)` is the only requirement; `sizeThatFits` and `displayPadding` have defaults and reserve room for drawing outside the glyphs; and it refines `Animatable`, which Part 4 builds on. Then the smallest renderer, one that draws every line unchanged.

### 6. Lines (~2 min)

Walk `RunsDiagram` down one level at a time, starting with lines and their bounds. Change one thing, dimming every other line, then give each line its own value: its distance from the current line sets its opacity and blur, which is the Focus effect from Part 1.

### 7. Runs (~2 min)

Runs split wherever attributes change, but nothing on a run says it's bold. A flag-style `TextAttribute`, attached with `.customAttribute(_:)`, makes a phrase addressable in `draw`; filling that run's bounds is the highlighter from Part 1, and it follows the wrap because the phrase is its own run on each line.

> **Lesson learned:** Runs don't expose bold, italic, or underline, so mark intent with your own attributes instead of inferring it from styling.

### 8. Glyphs, in every language (~3 min)

Glyphs are the smallest piece you can draw. "Hello, world" in five scripts, one per click, with each glyph's character indices: Arabic and Hebrew lines report `rightToLeft`, Hindi glyphs cover several characters, and an emoji with a skin tone is one glyph. The renderer is the same; SwiftUI did the shaping and ordering. End on the frozen wave from section 5: each glyph moved by a sine of its index, with no `phase` yet. Part 4 brings it to life.

> **Lesson learned:** Test effects in more than one language: scripts, content, emoji, and images.

## Part 3: Custom drawing (~6 min)

### 9. A delightful strikethrough (~4 min)

Goal: Particle's onboarding strike, each line crossed out in reading order. Try: Particle's pre-iOS 18 overlay, a struck clear copy scaled in from the leading edge, where every line grows at once. Refine: draw it ourselves, adding up the line widths, multiplying by `progress`, and letting each line take what it needs, so one strike flows across wrapped lines. Then the strike over Hebrew starts on the wrong side, and the fix asks the line's first run for its `layoutDirection` and starts the strike at `maxX`.

> **Lesson learned:** Ask the run for its `layoutDirection`, and don't assume left to right. Particle first shipped its strikethrough without RTL support.

### 10. Blur a phrase (~2 min)

Goal: the spoiler from Part 1. A marked run gets a blur filter, and a `revealed` value turns it down. The strikethrough added a shape on top of the text; the spoiler changes how one run itself draws. Adding shapes is one thing `draw` can do; the graphics context can fade, blur, move, recolor, and run shaders per line, run, or glyph, but it can't change where lines wrap.

> **Lesson learned:** Anything drawn outside the glyph bounds gets clipped unless `displayPadding` makes room for it. Particle's transcript clipped its last glyph until it reserved this room.

## Part 4: Animation and time (~14 min)

### 11. Let SwiftUI animate it (~4 min)

Expose `progress` as `animatableData`, and `withAnimation(.bouncy)` springs the strike, redirecting mid-flight. The frozen wave gains a `phase` and loops with one `repeatForever` animation of it. Then the title card's real reveal: a custom transition turns `progress` into a linear clock, and each emphasized glyph rises on its own spring with blur and opacity.

> **Lesson learned:** Honor Reduce Motion, don't override disabled animations, and mark motion-heavy transitions with `hasMotion`.

### 12. Values you own (~3 min)

Goal: Particle's podcast transcript. Try: Particle's first version, three styled `Text` segments rebuilt on every playback time change, where nothing can blur or move one word, and no animation curve can follow audio. Refine: attributes graduate from flags to data: a `WordTime` range on every word lets `draw` fade words in, or fill each one like the lyric from Part 1. Then "Audio as an animation value", once: a slider drives `TranscriptRenderer(time:)`, a `TimelineView` reads the `AVPlayer` every frame and builds a new renderer, and inside `draw` each word compares its `WordTime` range with the time.

### 13. Time travel: the podcast transcript (~4 min)

Particle's transcript, ported to macOS with a real clip: SwiftUI animates nothing; the current word, the line blur, and the scroll all come from the player's time, so scrubbing rewinds and fast-forwards with no state to undo. Every frame is a *pure function of time*.

> **Lesson learned:** A periodic time observer at 15 Hz looked choppy: a line change got only five frames. Read the player's time every frame instead.

> **Lesson learned:** Keep the `Text` stable so a new time only redraws: cache the text, or wrap it in an `Equatable` view, and attach a single leaf renderer with the values that change.

### 14. A pure function of time (~3 min)

A pure function of time is easy to test, debug, and preview. A snapshot test renders `Text(transcript).textRenderer(TranscriptRenderer(time: 12))` at one moment of the clip, and a style change fails it with a visual difference; a `#Preview` shows three moments side by side with no player. Even the highlight style is a value: swapping it restyles every word with no view code changes.

## Part 5: Footguns and pitfalls (~5 min)

### 15. Built-ins first (~1 min)

The Footguns section card pays off the asterisk on "simple" from Part 1. The first pitfall is reaching for a renderer at all: the built-in `.strikethrough` next to the renderer, both under the same `withAnimation`. The built-in appears at once while the renderer sweeps and springs, so if the strike doesn't need to move, the built-in is enough. Skip a renderer when a built-in already does the job, when you need different wrapping, or when motion gets in the way of reading.

### 16. VoiceOver (~0.5 min)

The PM's ticket from Part 1 asked for the spoiler "without spoiling it for VoiceOver," and a renderer alone doesn't meet it: it changes pixels, not what VoiceOver reads, so the spoiler still reads "the butler" out loud. Hide or stress for VoiceOver whatever you hide or stress on screen.

### 17. Smooth glyph motion (~1.5 min)

A small, slow wave at 1× pixels, enlarged: SwiftUI snaps glyphs to whole pixels so still text stays crisp, and for moving glyphs that snap is the jitter. `.disablesSubpixelQuantization` lets them glide; use it only for glyphs in motion.

### 18. Reading layout outside `draw` (~2 min)

Only `draw` knows where each line lands, and sooner or later another view wants that, like Particle's transcript scroll. Try: write the current line's position to a binding from `draw`, and SwiftUI warns "Modifying state during view update" on every frame. Refine: write to a plain class SwiftUI doesn't observe, and read it on the next render.

> **Lesson learned:** `draw` is a render callback. Never publish state from within it; it reports, it never triggers.

## Part 6: Build delight (~2 min)

### 19. Back to the start (~1 min)

The scorecard again, now with all four ingredients solved. Then the four effects from Part 1 replay together, now that the audience knows how each works; push values boldly while exploring, then dial back to what serves the moment.

### 20. Takeaways (~0.5 min)

A before → after recap, one line per click: `Text` broken into lines, runs, and glyphs; runs marked with attributes; driven by animations or your values; timers and callbacks become a pure function of time; built-ins first; just the right touch. Land the through-line one last time.

### 21. Resources (penultimate slide, ~0.25 min)

The one place the outside examples are linked:

- WWDC24 "Create custom visual effects with SwiftUI" (developer.apple.com/videos/play/wwdc2024/10151)
- Apple's `TextRenderer`, `TextAttribute`, and `.textRenderer(_:)` docs
- fatbobman's "Creating stunning dynamic text effects with TextRenderer"
- Prismic (github.com/twostraws/Prismic)

### 22. Thanks (final slide, ~0.25 min)

Contact info under a "Thank you" that ripples through the water distortion shader (a repeating animation of its phase + a Metal shader), then Q&A if there's time.

### Addendum: Combining renderers (Q&A only, after Thanks)

Shown only when a question asks about it. A renderer cascades like a font to every `Text` in a container, the closest renderer replaces the ones above it, and renderers never combine on their own; to combine effects, wrap one renderer in another.

---

## Where the outside examples show up

None are cited on stage; the penultimate slide carries the links.

| Source | What we borrow | Parts |
|---|---|---|
| WWDC24 session 10151 | Framing (small details add up; effects add personality and focus attention). The draw-every-line starting point. The spring + blur + opacity entrance with per-glyph stagger. A `Transition` driving elapsed time with a linear transaction. `.disablesSubpixelQuantization`. Line counts changing with locale and Dynamic Type. | 1, 2, 4, 5 |
| fatbobman's article | A sine wave over glyphs. `displayPadding` for drawing outside the glyphs. How styles split runs, and runs not exposing bold or italic. | 2, 3, 4 |
| Prismic | Dimmed alternate lines as the first tweak. The lines/runs/glyphs visualization. Attribute-based highlighting. The wave via `Animatable`. Water via a repeating animation + a distortion shader (Thanks slide). | 2, 4, 6 |

## Open items

- Still to build: recordings for the demo fallback.
- Timing: the part budgets add up to about 43 min. Cuts wait for two more rehearsals. Candidates: merge the three "pure function of time" statements, cut `PreviewMoments` or the style swap, merge history slides.
- Optional, if a rehearsal runs short (about 2 min each):
  - **Color and a shader on text** (Custom drawing): hue per glyph, then a color shader with glow. The abstract promises "beyond black-and-white pixels," and nothing in the talk shows it yet.
  - **The title reveal as an iteration** (Animation and time): line by line, then every glyph (too uniform), then only the emphasized words.
