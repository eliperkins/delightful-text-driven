import AVFoundation
import Observation

@Observable final class PlayerClock {
    private(set) var isPlaying = false
    private var scrubTime: TimeInterval?
    let duration: TimeInterval

    @ObservationIgnored private let player: AVPlayer
    @ObservationIgnored private var endObserver: Any?
    @ObservationIgnored private var resumeAfterScrub = false

    init(audio: URL, duration: TimeInterval) {
        player = AVPlayer(url: audio)
        self.duration = duration
        // The audio can be a hair shorter than the transcript, so a time boundary at `duration` might never be crossed.
        endObserver = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: player.currentItem, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.pause()
            }
        }
    }

    isolated deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    /// Not observed: read it from a `TimelineView`, which asks for it every frame.
    // slide: clockTime
    var time: TimeInterval {
        scrubTime
            ?? player.currentTime().seconds
    }
    // slide: end

    func toggle() {
        if isPlaying {
            player.pause()
        } else {
            if time >= duration {
                seek(to: 0)
            }
            player.play()
        }
        isPlaying.toggle()
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func scrub(to time: TimeInterval) {
        if scrubTime == nil {
            resumeAfterScrub = isPlaying
            player.pause()
        }
        scrubTime = time
    }

    func endScrub() {
        guard let scrubTime else { return }
        seek(to: scrubTime)
        if resumeAfterScrub {
            player.play()
        }
    }

    /// Holds the target time until the seek lands, so the transcript never jumps back to the old time.
    private func seek(to time: TimeInterval) {
        scrubTime = time
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            MainActor.assumeIsolated {
                if finished {
                    self?.scrubTime = nil
                }
            }
        }
    }
}

extension Snippets {
    static var clockTime: String { region("clockTime") }
}
