import SwiftUI

/// Back, position, forward, and restart in a Liquid Glass capsule. Restart needs a second click to confirm.
struct HoverControls: View {
    /// How long "Restart?" waits for the confirming click.
    static let restartConfirmationWindow: Duration = .seconds(3)

    @Environment(Presentation.self) private var presentation

    @State private var isConfirmingRestart = false

    var body: some View {
        GlassEffectContainer {
            HStack {
                HStack {
                    Button("Back", systemImage: "chevron.left") { presentation.back() }
                    position
                    Button("Forward", systemImage: "chevron.right") { presentation.forward() }
                }
                .labelStyle(.iconOnly)
                .padding()
                .glassEffect(.regular, in: .capsule)

                Button(isConfirmingRestart ? "Restart?" : "Restart", systemImage: "arrow.counterclockwise") {
                    if isConfirmingRestart {
                        presentation.restart()
                        isConfirmingRestart = false
                    } else {
                        isConfirmingRestart = true
                    }
                }
                .foregroundStyle(isConfirmingRestart ? .red : .primary)
                .padding()
                .glassEffect(.regular, in: .capsule)
            }
        }
        .fixedSize()
        .font(.title3)
        .buttonStyle(.borderless)
        .task(id: isConfirmingRestart) {
            guard isConfirmingRestart else { return }
            try? await Task.sleep(for: Self.restartConfirmationWindow)
            if !Task.isCancelled {
                isConfirmingRestart = false
            }
        }
    }

    /// "12 / 48", sized to the widest possible value so the capsule doesn't resize while clicking through.
    private var position: some View {
        let count = presentation.slideCount
        return ZStack {
            Text("\(count) / \(count)")
                .hidden()
            Text("\(presentation.position.slide + 1) / \(count)")
        }
        .monospacedDigit()
    }
}

#Preview {
    HoverControls()
        .environment(Presentation(deck: .talk, defaults: UserDefaults(suiteName: "preview")!))
        .padding()
        .background(Theme.background)
}
