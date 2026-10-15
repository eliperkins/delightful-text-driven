import SwiftUI

struct PresenterView: View {
    @Environment(Presentation.self) private var presentation

    var body: some View {
        VStack {
            TimingStrip()

            HStack(alignment: .top) {
                SlideThumbnail(position: presentation.position)
                nextColumn
                    .containerRelativeFrame(.horizontal, count: 3, span: 1, spacing: 0)
            }
            .layoutPriority(1)

            Divider()

            actions

            notes

            HoverControls()
        }
        .padding()
    }

    private var nextColumn: some View {
        VStack(alignment: .leading) {
            Text("Next")
                .font(.headline)
                .foregroundStyle(.secondary)

            if let next = presentation.nextPosition {
                SlideThumbnail(position: next)
            } else {
                ContentUnavailableView("End of Deck", systemImage: "flag.checkered")
                    .aspectRatio(Theme.Layout.canvas, contentMode: .fit)
            }

            stepDots
                .font(.title2)
        }
    }

    private var stepDots: some View {
        let steps = presentation.currentSlide.steps
        let step = presentation.position.step
        return HStack {
            ForEach(0..<steps, id: \.self) { index in
                Image(systemName: index <= step ? "circle.fill" : "circle")
                    .foregroundStyle(presentation.currentSlide.actions(at: index).isEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step + 1) of \(steps)")
    }

    @ViewBuilder private var actions: some View {
        let actions = presentation.currentSlide.actions(at: presentation.position.step)
        if !actions.isEmpty {
            HStack {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    if index > 0 {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                    }
                    Label(action.title, systemImage: action.systemImage)
                }
            }
            .font(.largeTitle.bold())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.tint.quaternary, in: .capsule)
            .accessibilityElement(children: .combine)
        }
    }

    private var notes: some View {
        let text = presentation.currentSlide.notes
        return ScrollView {
            Group {
                if text.isEmpty {
                    Text("No notes")
                        .foregroundStyle(.secondary)
                } else {
                    Text(Self.markdown(text))
                }
            }
            .font(.largeTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity)
    }

    private static func markdown(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}

struct SlideThumbnail: View {
    let position: Presentation.Position

    @Environment(Presentation.self) private var presentation

    var body: some View {
        let slide = presentation.deck.slides[position.slide]
        SlideCanvas {
            slide.rendered(step: position.step)
                .id(position.slide)
        }
        .aspectRatio(Theme.Layout.canvas, contentMode: .fit)
        .environment(\.slideRenderMode, .thumbnail)
        .allowsHitTesting(false)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    let presentation = Presentation(deck: .talk, defaults: UserDefaults(suiteName: "preview")!)
    presentation.jump(toSlideNumber: 4)
    presentation.forward()
    return PresenterView()
        .environment(presentation)
        .frame(width: 1440, height: 900)
}
