import AVFoundation
import SwiftUI

struct LoopingVideo: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> PlayerView {
        let view = PlayerView(url: url)
        view.player.play()
        return view
    }

    func updateNSView(_ view: PlayerView, context: Context) {}

    static func dismantleNSView(_ view: PlayerView, coordinator: ()) {
        view.player.pause()
    }

    final class PlayerView: NSView {
        let player = AVQueuePlayer()
        private let looper: AVPlayerLooper

        init(url: URL) {
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
            super.init(frame: .zero)
            player.isMuted = true
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            layer = playerLayer
            wantsLayer = true
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
