import SwiftUI

extension Deck {
    /// The talk, in order.
    static let talk = Deck {
        Part(.hook) {
            TitleCard()
                .notes("Up while people sit down. The timer starts on the first click. LFG!!! Passion")
            Screens()
                .notes("""
                Many apps today are text heavy, creating information dense UI
                **PAUSE**
                On a screen this small, text does most of the work, so how it looks and moves counts.
                """)
            Era(year: "2008", os: "iPhone OS 2", apis: ["`UILabel`", "`UITextField`", "`UITextView`", "`UIWebView`"])
                .notes("""
                Overwhelm on purpose: fast cuts, about 15 seconds each.
                In the beginning, there were helpful primitives like UILabel. Things were hard to customize deeply, but kind of on purpose.
                Combining multiple labels for styling, hoping you got the layout just right at 320px.
                Rich text meant HTML in a web view.
                """)
            Era(year: "2010", os: "iOS 3.2", apis: ["Core Text", "`NSAttributedString`"])
                .notes("Low-level APIs for more complex drawing of text. The first glyph access on iOS: lines, runs, glyph positions. Only Core Text could draw a multi-style string, and new APIs started to pop up, but not many great ways to use them.")
            Era(year: "2012", os: "iOS 6", apis: ["`UILabel.attributedText`", "`UITextView.attributedText`", "`UITextField.attributedText`"])
                .notes("Mixed styles in the standard controls, without Core Text or a web view. More controls got more flexibility in what they were rendering.")
            Era(year: "2013", os: "iOS 7", apis: ["TextKit", "Dynamic Type"])
                .notes("""
                Layout manager, text storage, text containers: glyph ranges and glyph rects. More complex APIs that would make your eyes roll.

                Dynamic Type allowed text to follow the user's size setting.
                """)
            Era(year: "2019", os: "iOS 13", apis: ["SwiftUI `Text`"])
                .notes("Text becomes a value. Declarative UI in SwiftUI meant that you describe it, and SwiftUI does the layout and the drawing.")
            Era(year: "2021", os: "iOS 15", apis: ["TextKit 2", "`AttributedString`", "Markdown in `Text`"])
                .notes("TextKit 2 gave us a new layout engine built on layout fragments, with no glyph APIs by design. AttributedStrings in SwiftUI were a new value-type attributed string that `Text` renders. Create them via Markdown.")
            Era(year: "2022", os: "iOS 16", apis: ["TextKit 2 by default", "`.numericText()`"])
                .notes("`UITextView` uses TextKit 2 by default. Delightful, built-in per-character animation in SwiftUI, for digits only.")
            Statement("iOS never lacked ways to *display* text.")
            SpoilerReplica()
                .notes("""
                But text doesn't have to be static. One phrase blurs, and nothing else does. How would you build it?
                A shader can't find the phrase; an attributed string can't blur it.
                You start trying to find the positions of the glyphs, depending on the length of the word
                """)
            Requirements()
                .steps(Requirements.items.count)
                .notes("""
                Read the requirements one line at a time. Each one sounds small. Together they rule out every quick hack.
                Bigger text moves the phrase. Another language moves it again, or flips it right to left.
                """)
            HighlighterReplica()
                .notes("Next: a highlight that follows the phrase onto the next line, in reading order. An overlay can't follow the wrap.")
            FocusReplica()
                .notes("Focus: one value decides how sharp each line is. The line you're on is clear; the rest steps back.")
            LyricReplica()
                .notes("Lyrics: each word fills as it's sung. The word is drawn twice, dim and then clipped to how far it's been sung.")
            Statement("How?", style: .display, alignment: .center)
                .notes("**PAUSE** for 3 seconds. Let the question land before you continue.")
            Makes()
                .steps(3)
                .notes("""
                Effects like these used to mean complex measurements and calculations.
                Click: simple. Mostly. Hold on to that asterisk; we'll come back to it.
                """)
            Hello()
                .steps(4)
                .notes("""
                Eli Perkins. 15+ years of iOS, starting when the iPad launched.
                At most places on the internet, I'm "eliperkins".
                """)
            AboutParticle()
                .notes("""
                Particle is an app to help you learn more, faster: the news and podcasts you care about, at your fingertips.
                An app where we deeply care about polish, where text polish matters.
                """)
            AboutParticle(showsAwards: true)
            Screens(
                names: ["screen-particle-home", "screen-particle-story", "screen-particle-article", "screen-particle-topic"],
                cropsStatusBar: false
            )
            Recording(name: "particle-onboarding", aspectRatio: 1206.0 / 1546.0)
                .notes("""
                This ships. Onboarding: each finished step strikes through, line by line like someone crossing things off on a list.
                """)
            Recording(name: "particle-clips", aspectRatio: 996.0 / 932.0)
                .notes("""
                When we brought podcast clips into Particle last year, we embarked on a journey of different APIs and approaches to create a delightful UI that worked for users who just wanted to read an interesting transcript, or one for users who want to listen to minutes or hours of podcasts.
                Pause and reset before the technical part.
                """)
            Statement("Why is delightful text *so hard*?")
                .notes("Apple gives us many text APIs, and effects like these still take weeks. Why?")
            Scorecard(label: "Text rendering", buildsIn: true)
                .steps(4)
                .notes("""
                Four things every text effect needs.
                1. Layout: the work of putting text in place. Wrapping, line breaks, Dynamic Type, font fallback, bidirectional order.
                2. Positions: asking where it went. Where each line, word, and glyph ended up, so you can draw something at them.
                3. Drawing the text itself: a way to draw each piece differently.
                4. Values over time: something that moves the effect, like an animation or a clock.
                Imperative UI needs complex state and complicated transforms whenever anything changes: the area to lay out in, measuring, breaking lines, tracking state, drawing each glyph.
                """)
            Scorecard(label: "SwiftUI.Text", marks: [.layout: .solved, .positions: .sealed, .drawing: .sealed, .change: .solved])
                .notes("""
                With SwiftUI, `Text` is a value. SwiftUI owns wrapping, Dynamic Type, localization, and bidirectional text, and state changes drive animation. It makes things **easy** again. Values over time is solved for animations; a clock, like an audio player, is another story, and we'll get there.
                But it never told you the positions. Nothing told you where line two ended or where a word's glyphs sat, and there was no hook to draw text differently. Animated text meant styled segments, overlays, masks, and `scaleEffect`.
                """)
            Statement("`TextRenderer` opens up *positions* and *drawing*.")
        }
        Part(.lines) {
            SectionCard()
            ApplyRenderer()
                .notes("""
                First, how you use one: a single modifier on a Text, like font. This renderer draws the text unchanged; we'll build it next.
                .textRenderer applies to every Text inside it, and the closest one wins.
                """)
            RendererProtocol()
                .steps(4)
                .notes("""
                The whole API on one slide. A protocol, one required method, two optional ones.
                Click: draw. SwiftUI hands you the laid-out text and a GraphicsContext. You decide what to draw.
                Click: sizeThatFits and displayPadding have defaults. They reserve room when you draw outside the glyphs.
                Click: it refines Animatable, so a renderer's values can animate like any other. We'll get there.
                """)
            MeetTextRenderer()
                .steps(2)
                .notes("""
                The smallest renderer there is.
                Click: draw every line unchanged. Nothing looks different, but now we hold the pen.
                """)
            StripedLines()
                .notes("Change one thing: dim every other line. We can treat each line differently.")
            FocusCode()
                .notes("""
                One value per line. Each line's distance from the current line sets its opacity and blur.
                That's the Focus effect from the start.
                """)
            FocusCode(highlightsFilter: true)
                .notes("The blur is a filter on a copy of the context. It touches only the line that copy draws.")
            RunsDiagram(level: .lines)
                .notes("The pieces SwiftUI hands to you to draw, already laid out. We'll go down one level at a time. First, lines, each with its bounds.")
            RunsDiagram(level: .runs)
                .notes("One level down: runs. Runs split wherever attributes change. The bold word gets its own run, but nothing on the run says it's bold. The flagged run says Highlight because we put that attribute there.")
            HighlightRuns()
                .steps(2)
                .notes("""
                A TextAttribute is a flag you define and attach with customAttribute. On its own, it changes nothing on screen, but it gives your renderer a value to check for.
                Click: the renderer finds the flagged run and fills its bounds before it draws the run. From here on, code shows only the inside of draw.
                """)
            HighlighterReplica()
                .notes("And that's the highlighter from the start. The marked phrase is its own run on each line, so the fill follows the wrap.")
            RunsDiagram(level: .glyphs)
                .notes("The last level: glyphs, the smallest piece you can draw.")
            EveryLanguage()
                .steps(Greeting.all.count)
                .notes("""
                Glyphs in any script. Hello, world in five scripts, one per click. The renderer is the same; SwiftUI did the shaping and ordering.
                Arabic and Hebrew: the line says rightToLeft, and the character indices count down from the right.
                Hindi: one glyph covers several characters, so the indices skip. A glyph isn't always a character. Emoji: the hand and its skin tone are two scalars, four UTF-16 units, drawn as one glyph.
                Real text is user-generated: names, quotes, and transcripts, in every script, with emoji. The renderer gets all of it already laid out.
                Test effects in more than one language: scripts, content, emoji, images.
                """)
            GlyphWave()
                .notes("""
                The wave from the start of this part. Draw each glyph on its own. Move each one up or down by a sine of its index, and the text becomes a wave.
                It's frozen for now. We'll bring it to life soon.
                """)
        }
        Part(.drawing) {
            SectionCard()
            Recording(name: "particle-onboarding", aspectRatio: 1206.0 / 1546.0)
                .notes("Goal: Particle's onboarding strike. Each line crossed out in reading order, like a pen.")
            OverlayStrike()
                .actions(.press("Strike"), .press("Restore"))
                .notes("""
                Try: Particle's strikethrough before iOS 18. A clear copy of the text, struck, scaled in from the leading edge.
                Strike it: every line grows at once, not one line after the other. Restore it: the strike is gone with no animation.
                """)
            StrikethroughLines()
                .steps(3)
                .actions(.drag("the slider"), at: 2)
                .notes("""
                Refine: draw it ourselves. Add up the line widths and multiply by progress.
                Click: half. Each line takes what it needs from the distance that's left, so one strike flows across wrapped lines.
                Click: all of it. Drag the slider to scrub back and forth.
                """)
            StrikethroughDirection()
                .steps(2)
                .actions(.drag("the slider"))
                .notes("""
                Look: the strikethrough over Hebrew. Drag the slider: it starts on the left, against the reading direction. (Over Arabic, a strike at the middle of the line hides in the joining line between letters.)
                Click: refine. Ask each run for its direction, and strike it from the right when it's rightToLeft.
                """)
            Statement("Ask the run for its `layoutDirection`. *Don't assume left to right.*", style: .statementCompact)
                .notes("When we first shipped Particle's new strikethrough, we didn't support strikethrough in RTL. Asking the run for its layout helps us understand which direction to strike from and to.")
            SpoilerReplica()
                .notes("Goal: the spoiler from the start. The strikethrough added a shape on top of the text. The spoiler changes how one phrase itself draws: a filter on one run.")
            SpoilerCode()
                .steps(2)
                .actions(.drag("the slider"))
                .notes("""
                The marked run gets a blur filter, and revealed turns it down. Drag the slider to reveal the butler.
                Click: a blur spreads past the glyphs. displayPadding reserves room around the text for what you draw. Particle's transcript clipped its last glyph until it reserved this room.
                """)
            Statement("*Fade, blur, move, recolor, run shaders*. No need to calculate text or glyph positions.", style: .statementCompact)
                .notes("Adding shapes is one thing draw can do. The graphics context can do anything a Canvas can, per line, run, or glyph. The one thing you can't change is where lines wrap.")
        }
        Part(.animation) {
            SectionCard()
            AnimateStrike()
                .actions(.press("Strike"), .press("Strike again mid-flight"))
                .notes("""
                The same strikethrough. TextRenderer can implement Animatable, so exposing progress as animatableData is all it takes. SwiftUI handles the value changes for you.
                Press Strike, then press again mid-flight: SwiftUI redirects the spring. The clamp stops the bounce from drawing the strike backward.
                Opt into SwiftUI's animation, and you get its behavior for free: springs, interruptions, and transactions.
                """)
            WaveText()
                .notes("""
                Remember the frozen wave? Make phase its animatableData, the same as progress on the strike.
                Then loop it: the only animation code is a repeating linear animation of phase. No timer, no display link.
                """)
            TitleCard(revealStep: 1)
                .steps(2)
                .notes("""
                Perhaps we wanted to bring some flair to our title slide intro.
                Click: the title from the start of the talk, with its real animation.
                """)
            RevealCode()
                .steps(2)
                .actions(.press("Replay"), at: 1)
                .notes("""
                One clock, many springs. A custom transition sets progress and makes it linear, so progress works as a clock. Each emphasized glyph starts a little later on that clock. The rest of the text just fades in.
                Only the emphasized words get the full treatment: the same kind of attribute as the highlight.
                Click: each glyph rises on its own spring, comes into focus, and fades in. Hit Replay. Glyphs, like the wave, now each on their own clock.
                """)
            Statement("Don't forget to *honor Reduce Motion.*")
                .notes("Don't override disabled animations. Mark motion-heavy transitions with hasMotion. These animations are meant to draw attention, but Reduce Motion should be respected first.")
            Recording(name: "particle-clips", aspectRatio: 996.0 / 932.0)
                .notes("Goal: Particle's podcast transcript. Every word lights up as it's spoken.")
            SegmentedTranscript()
                .actions(.press("Play"))
                .notes("""
                Try: Particle's first transcript. Three styled `Text` segments, rebuilt every time the playback time changes.
                Play it: the highlight jumps from word to word. Nothing can blur or move one word.
                Look: and an animation can't help either. A transcript follows audio, not an animation curve.
                """)
            WordTimes()
                .steps(2)
                .actions(.drag("the slider"), at: 1)
                .notes("""
                Refine: a renderer takes values, and an attribute can carry data too. Tag each word with the time range when it's spoken, and we can highlight it when its time comes.
                Click: the renderer compares every run with the current time and fades words in as they're spoken. Drag the slider to scrub. Particle's transcript works this way.
                """)
            LyricCode()
                .actions(.drag("the slider"))
                .notes("""
                Refine: fade is one option. The lyric from the start draws each word twice: dim, then clipped to how much of the word has been sung.
                Drag the slider: the fill moves through each word, not just from word to word. It asks each run for its direction too, so it fills right to left in Hebrew or Arabic.
                """)
            TimeTravelCode()
                .steps(3)
                .actions(.drag("the slider"))
                .notes("""
                Now the transcript's own renderer. Our code owns time, not SwiftUI's animation. Drag the slider: each change builds a new renderer, and SwiftUI draws the same layout with it. This is really helpful in demo playgrounds or in previews during development.
                Click: during playback, an animation can't help: it moves a value toward a target. A clock has no target, and we don't own it, so a TimelineView redraws every frame and asks the player for its time. A periodic time observer at 15 Hz looked choppy: a line change got only five frames. Every frame costs power, up to 120 a second on ProMotion, so the TimelineView pauses when the clip pauses.
                Click: inside draw, each word compares its WordTime range with the time. Spoken words are ink, the current word gets the pill, and the rest wait.
                Keep the Text stable: cache the text builder, or wrap it in an Equatable view, and attach a single leaf TextRenderer with values that change. A new time only redraws.
                """)
            TranscriptSlide()
                .actions(.press("Play"), .drag("the scrubber"))
                .notes("""
                Here's Particle's podcast clip text render, with the real transcript: Sara Beykpour, Particle's CEO, on Generative Now, on how she learned Periscope had already sold to Twitter. Press Play. SwiftUI animates nothing here: the current word, the line blur, and the scroll all come from the player's time.
                Drag the scrubber back and forth. The transcript rewinds and fast-forwards with no state to undo. Fallback recording is ready.
                """)
            Statement("Every frame is a *pure function of time*.")
            Statement("A pure function of time is *easy to test*.")
                .notes("Render fixed timestamps with ImageRenderer in unit tests.")
            Statement("A pure function of time is *easy to debug*.")
            Statement("A pure function of time is *easy to preview*.")
            PureTimeCode()
                .steps(2)
                .notes("""
                A snapshot test, in the style of swift-snapshot-testing. Motion is hard to test because it changes every frame. But each frame is a function of time, so pick a moment that matters and record an image of it. Here, 12 seconds in, in the middle of "because". No player, no waiting.
                Click: a designer asks for the spotlight style instead of the pill. Change one line, and the test at 12 seconds fails: the reference, what we drew now, and the difference. Every pixel that changed lights up, so you review a style change as a picture, not a description.
                """)
            PreviewMoments()
                .notes("The same idea while you build: a preview with three moments of the clip, side by side, with no player. Change the renderer and all three update as you type.")
            StyleSwap()
                .actions(.press("Swap style"))
                .notes("""
                Even styling can be a value passed to renderers. Switch it: every word restyles, and no view code changes.

                This can be helpful for testing or tweaking, feature flagging or debugging too.
                """)
        }
        Part(.pitfalls) {
            SectionCard()
                .notes("Remember the asterisk on simple? Here it is: four things to watch out for before you ship one of these.")
            StrikeComparison()
                .actions(.press("Strike"))
                .notes("""
                The first pitfall is reaching for a renderer at all. Both texts get the same withAnimation(.bouncy). The built-in strike appears all at once. The renderer draws its strike across each line in reading order, and it springs.
                If the strike doesn't need to move, the built-in is enough. Decide if the motion is worth it.
                """)
            Statement("Skip it when a built-in *already does the job*.")
                .notes("Or when you need different wrapping, or when motion gets in the way of reading. A built-in gets accessibility, Dynamic Type, and future OS polish for free.")
            Statement("A renderer changes pixels, *not what VoiceOver reads*.")
                .notes("""
                Remember the ticket: "without spoiling it for VoiceOver." A renderer only draws. VoiceOver still reads the whole Text, so the spoiler reads "the butler" out loud.
                Whatever you hide or stress on screen, hide or stress for VoiceOver too, with an accessibility label.
                """)
            SubpixelWave()
                .steps(2)
                .notes("""
                A small, slow wave, drawn at 1× and blown up so you can see every pixel. Look at the top one: each glyph jumps a whole pixel at a time. SwiftUI snaps glyphs to whole pixels so still text stays crisp. For moving glyphs, that snap is the jitter. At full size it's subtle, but you feel it in slow motion.
                Click: one option on draw. The bottom word is the same code with disablesSubpixelQuantization: its edges soften between pixels, and it glides. Use it only for glyphs in motion; still text looks sharper with the snap.
                """)
            Statement("Reading layout values *outside of* `draw`.", kicker: "⚠️ Here be dragons 🐉")
                .notes("Only draw knows where each line lands. Sooner or later, another view wants that: a scroll view, a tooltip pinned to a word, a marker beside a line. In Particle, the transcript's scroll view needed to know where the current line is. The transcript you saw earlier scrolls inside draw, so it stays a pure function of time. Particle's app scrolls a real ScrollView, and that's where it needs the line from draw.")
            LineReport(handoff: .state)
                .steps(2)
                .notes("""
                Try: the obvious way. Give the renderer a binding and write the current line's center to it from draw.
                Click: the marker reads that state. It works. But look under it: SwiftUI warns "Modifying state during view update" on every frame. Each warning is undefined behavior. In Particle, the scroll moved what draw could see, draw reported a new line, and the scroll moved again.
                """)
            LineReport(handoff: .reference)
                .steps(2)
                .notes("""
                Refine: draw writes to a plain class that SwiftUI doesn't observe. Writing to it changes nothing, so nothing redraws.
                Click: the next render reads what the last draw wrote. The TimelineView renders every frame anyway, so the marker is at most one frame behind. Zero warnings.
                """)
            Statement("Never publish state *from within* `draw`.")
                .notes("draw reports, it never triggers. Write to a reference, and read it on the next render.")
        }
        Part(.close) {
            SectionCard()
            Scorecard(label: "SwiftUI.Text + TextRenderer", marks: [.layout: .solved, .positions: .solved, .drawing: .solved, .change: .solved])
                .notes("Back to the scorecard. SwiftUI still owns layout and change. TextRenderer opened up positions and drawing.")
            Replay()
                .notes("""
                The four effects from the start, together. Now you know how each one works: an attribute, run bounds, one value per line, a word clipped and drawn twice.
                Push values boldly while you explore, then dial back to what serves the moment.
                """)
            Takeaways()
                .steps(Takeaways.all.count)
                .notes("""
                One line per click.
                A Text used to be one sealed block. Break it down, and it's lines, runs, and glyphs, already laid out for us.
                Click: mark the runs that matter with attributes, and style them however we want: the highlight, the spoiler, the time on every word.
                Click: and it doesn't sit still. Let SwiftUI animate it, or drive it with our own values: a slider, the clock, the audio player.
                Click: when a clock drives it, make every frame a pure function of time. Scrub it, test it, and preview it, with no state to undo.
                Click: but built-ins first. Keep draw pure, and smooth out moving glyphs.
                Click: TextRenderer brings delight with just the right touch. Pause here.
                """)
            Statement("Text doesn't need to be boring. *Delight your users with the right flourish.*", style: .statementCompact)
            Resources()
                .notes("The one place the links live. Leave it up a moment for photos.")
            Thanks()
                .notes("Contact info. Q&A if there's time. For a question about combining renderers, skip ahead to the addendum.")
            Cascade()
                .steps(2)
                .notes("""
                Addendum, for Q&A only. A renderer cascades like a font: one textRenderer on a container reaches every Text inside it. The closest renderer replaces the ones above it, so the struck line loses the wave. Renderers never combine on their own.
                Click: to combine effects, wrap one renderer in another. Counted calls its base renderer's draw, then adds its own work.
                """)
        }
    }
}
