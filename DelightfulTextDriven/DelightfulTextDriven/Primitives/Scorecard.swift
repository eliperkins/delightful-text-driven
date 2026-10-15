import SwiftUI

struct Scorecard: View {
    enum Ingredient: CaseIterable {
        case layout, positions, drawing, change

        var title: String {
            switch self {
            case .layout: "Layout"
            case .positions: "Positions"
            case .drawing: "Drawing"
            case .change: "Values over time"
            }
        }
    }

    enum Mark {
        case solved
        case sealed
    }

    let label: String
    var marks: [Ingredient: Mark] = [:]
    var buildsIn = false

    var body: some View {
        Slide(label: label) {
            Grid(
                alignment: .leadingFirstTextBaseline,
                horizontalSpacing: Theme.Layout.scorecardColumnSpacing,
                verticalSpacing: Theme.Layout.scorecardRowSpacing
            ) {
                ForEach(Array(Ingredient.allCases.enumerated()), id: \.element) { index, ingredient in
                    row(ingredient, number: index + 1)
                        .build(at: buildsIn ? index : 0)
                }
            }
            .padding(.top, Theme.Layout.contentTop)
            .padding(.bottom, Theme.Layout.splitBottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private func row(_ ingredient: Ingredient, number: Int) -> some View {
        let mark = marks[ingredient]
        return GridRow {
            Text(number, format: .number)
                .slideText(SlideText.statement.color(Theme.accentText))
            Text(ingredient.title)
                .slideText(SlideText.statement.color(mark == .sealed ? Theme.muted : Theme.ink))
                .frame(maxWidth: .infinity, alignment: .leading)
            if let mark {
                Image(systemName: mark == .solved ? "checkmark.circle.fill" : "lock.fill")
                    .slideText(SlideText.statement.color(mark == .solved ? Theme.accentText : Theme.muted))
                    .accessibilityLabel(mark == .solved ? "Solved by SwiftUI" : "Sealed off")
                    .gridColumnAlignment(.center)
            }
        }
    }
}

#Preview {
    SlidePreview(part: .hook) {
        Scorecard(label: "SwiftUI.Text", marks: [.layout: .solved, .positions: .sealed, .drawing: .sealed, .change: .solved])
    }
}
