import SwiftUI

/// A 🧠, centered. The prompt to the crowd is in the notes.
struct Imagine: View {
    var body: some View {
        Slide {
            Text("🧠")
                .slideText(.hero)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview {
        Imagine()
    }
}
