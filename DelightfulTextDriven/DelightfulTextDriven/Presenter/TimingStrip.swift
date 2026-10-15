import SwiftUI

struct TimingStrip: View {
    static let slot: Duration = .seconds(45 * 60)

    @Environment(Presentation.self) private var presentation

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let elapsed = presentation.elapsed(at: context.date)
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text(context.date, format: .dateTime.hour().minute())
                    Spacer()
                    remaining(elapsed: elapsed)
                }
                .font(.largeTitle.monospacedDigit())

                HStack(alignment: .top) {
                    ForEach(TalkPart.allCases, id: \.self) { part in
                        partCell(part, elapsed: elapsed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .monospacedDigit()
            }
        }
    }

    @ViewBuilder
    private func remaining(elapsed: Duration?) -> some View {
        if let elapsed {
            let left = Self.slot - elapsed
            if left >= .zero {
                Text("\(left.minuteSecond) left")
            } else {
                Text("\((elapsed - Self.slot).minuteSecond) over")
                    .foregroundStyle(.red)
            }
        } else {
            Text("\(Self.slot.minuteSecond) · starts on the first click")
                .foregroundStyle(.secondary)
        }
    }

    private func partCell(_ part: TalkPart, elapsed: Duration?) -> some View {
        let isCurrent = part == presentation.currentSlide.part
        return VStack(alignment: .leading) {
            Text(part.title)
                .font(.headline)
                .foregroundStyle(isCurrent ? .primary : .secondary)

            Text("Plan \(part.plannedStart.minuteSecond)")
                .foregroundStyle(.secondary)

            if let actual = presentation.actualStart(of: part) {
                let late = actual - part.plannedStart
                Text("Actual \(actual.minuteSecond) (\(late.signedMinuteSecond))")
                    .foregroundStyle(late > .zero ? .red : .green)
            }

            if isCurrent, let elapsed, let actual = presentation.actualStart(of: part) {
                Text("\((elapsed - actual).minuteSecond) of \(part.budget.minuteSecond)")
            }
        }
    }
}

private extension Duration {
    var minuteSecond: String {
        (self < .zero ? .zero - self : self).formatted(.time(pattern: .minuteSecond))
    }

    var signedMinuteSecond: String {
        (self > .zero ? "+" : self < .zero ? "−" : "±") + minuteSecond
    }
}

#Preview {
    TimingStrip()
        .environment(Presentation(deck: .talk, defaults: UserDefaults(suiteName: "preview")!))
        .padding()
        .frame(width: 1440)
}
