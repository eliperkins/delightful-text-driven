import SwiftUI
import UniformTypeIdentifiers

@main
struct DeckApp: App {
    @State private var talk = Presentation(deck: .talk)
    @State private var keyMonitor = KeyMonitor()
    @State private var stage = Stage()

    #if DEBUG
    // Its own defaults suite, so browsing the gallery never moves the talk's saved slide.
    @State private var gallery = Presentation(
        deck: .themeGallery,
        defaults: UserDefaults(suiteName: DebugOptions.themeGalleryKey) ?? .standard
    )
    @AppStorage(DebugOptions.themeGalleryKey) private var showsThemeGallery = false
    @AppStorage(DebugOptions.layoutGuidesKey) private var showsLayoutGuides = false
    @AppStorage(DebugOptions.hiddenBuildsKey) private var revealsHiddenBuilds = false
    #endif

    /// The deck being presented: the talk, or the theme gallery when the Debug menu asks for it.
    private var presentation: Presentation {
        #if DEBUG
        if showsThemeGallery {
            return gallery
        }
        #endif
        return talk
    }

    var body: some Scene {
        Window("Audience", id: DeckCommands.audienceWindowID) {
            AudienceView()
                .environment(presentation)
                #if DEBUG
                .environment(\.showsLayoutGuides, showsLayoutGuides)
                .environment(\.revealsHiddenBuilds, revealsHiddenBuilds)
                #endif
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .windowToolbarFullScreenVisibility(.onHover)
                .persistentSystemOverlays(.hidden)
                .background(WindowAccessor { stage.register($0, as: .audience) })
                .onChange(of: ObjectIdentifier(presentation), initial: true) {
                    keyMonitor.route(to: presentation, stage: stage)
                }
        }
        .windowStyle(.hiddenTitleBar)
        // The canvas has no natural size of its own, so the window always needs one from here.
        .defaultSize(Theme.Layout.canvas)
        // Once any scene asks to be presented at launch, SwiftUI stops opening the first scene on its own.
        .defaultLaunchBehavior(.presented)
        .commands {
            DeckCommands(presentation: presentation, stage: stage)
            #if DEBUG
            CommandMenu("Debug") {
                Toggle("Theme Gallery", isOn: $showsThemeGallery)
                    .keyboardShortcut("t", modifiers: [.command, .control])
                Toggle("Layout Guides", isOn: $showsLayoutGuides)
                    .keyboardShortcut("g", modifiers: [.command, .control])
                Toggle("Reveal Hidden Builds", isOn: $revealsHiddenBuilds)
                    .keyboardShortcut("b", modifiers: [.command, .control])
            }
            #endif
        }

        Window("Presenter", id: DeckCommands.presenterWindowID) {
            PresenterView()
                .environment(presentation)
                .background(WindowAccessor { stage.register($0, as: .presenter) })
        }
        .defaultSize(Theme.Layout.canvas)
        .defaultLaunchBehavior(.presented)
        // Without this, SwiftUI adds its own Window menu item next to `DeckCommands`.
        .commandsRemoved()
    }
}

private struct DeckCommands: Commands {
    static let audienceWindowID = "audience"
    static let presenterWindowID = "presenter"

    let presentation: Presentation
    let stage: Stage

    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandMenu("Slides") {
            // Navigation keys go through `KeyMonitor`; these items are for discoverability and the mouse.
            Button("Next") { presentation.perform(.forward) }
            Button("Previous") { presentation.perform(.back) }
            Divider()
            Button("Black Screen") { presentation.perform(.toggleBlackout) }
            Button("Restart") { presentation.perform(.restart) }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            Divider()
            Button(stage.isPresenting ? "Stop Presenting" : "Present") {
                if !stage.isPresenting {
                    openWindow(id: Self.audienceWindowID)
                    openWindow(id: Self.presenterWindowID)
                }
                stage.togglePresenting()
            }
            .keyboardShortcut(.return, modifiers: .command)
            Button("Swap Displays") { stage.swapDisplays() }
                .disabled(!stage.isPresenting)
            Divider()
            Button("Export Stills…") { exportStills() }
            Button("Export PDF…") { exportPDF() }
        }
        CommandGroup(after: .windowArrangement) {
            Button("Presenter Window") { openWindow(id: Self.presenterWindowID) }
                .keyboardShortcut("p", modifiers: [.command, .option])
        }
    }

    private func exportStills() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Slides"
        panel.prompt = "Export"
        guard panel.runModal() == .OK, let folder = panel.url else { return }
        export { try DeckExport(deck: presentation.deck).writeStills(to: folder) }
    }

    private func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "Slides.pdf"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        export { try DeckExport(deck: presentation.deck).writePDF(to: url) }
    }

    private func export(_ write: () throws -> Void) {
        do {
            try write()
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}
