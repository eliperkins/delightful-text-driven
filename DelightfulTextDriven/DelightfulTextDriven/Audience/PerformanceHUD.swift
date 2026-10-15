import Darwin
import QuartzCore
import SwiftUI

struct PerformanceHUD: View {
    static let interval: Duration = .seconds(0.5)
    static let backgroundOpacity = 0.85

    @State private var sample = Sample()
    @State private var window: NSWindow?

    var body: some View {
        Grid(alignment: .leading) {
            row("HZ", "\(sample.refreshesPerSecond)")
            row("DRAWS/S", "\(sample.drawsPerSecond)")
            row("CPU", "\(sample.cpuPercent)", unit: "%")
        }
        .font(.largeTitle.monospaced())
        .padding()
        .background(Theme.codeBackground.opacity(Self.backgroundOpacity), in: .rect(corners: .concentric, isUniform: true))
        .padding()
        .allowsHitTesting(false)
        .background(WindowAccessor { found in
            Task { window = found }
        })
        .task(id: window) {
            guard let window else { return }
            let frames = FrameCounter(window: window)
            defer { frames.stop() }
            DrawCounter.shared.drain()
            var cpuSeconds = Sample.cpuSeconds()
            var start = ContinuousClock.now
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.interval)
                let now = ContinuousClock.now
                let cpuNow = Sample.cpuSeconds()
                sample = Sample(refreshes: frames.drain(), draws: DrawCounter.shared.drain(), cpuSeconds: cpuNow - cpuSeconds, interval: start.duration(to: now))
                cpuSeconds = cpuNow
                start = now
            }
        }
    }

    private func row(_ label: String, _ value: String, unit: String = "") -> some View {
        GridRow {
            Text(label)
            Text(value)
                .foregroundStyle(Theme.ink)
                .gridColumnAlignment(.trailing)
            Text(unit)
        }
        .foregroundStyle(Theme.muted)
    }
}

private struct Sample {
    var refreshesPerSecond = 0
    var drawsPerSecond = 0
    /// This process only, measured over the interval like Activity Monitor: one full core is 100.
    var cpuPercent = 0

    init() {}

    init(refreshes: Int, draws: Int, cpuSeconds: Double, interval: Duration) {
        let seconds = interval / .seconds(1)
        refreshesPerSecond = Int((Double(refreshes) / seconds).rounded())
        drawsPerSecond = Int((Double(draws) / seconds).rounded())
        cpuPercent = Int((cpuSeconds / seconds * 100).rounded())
    }

    /// User plus system time of this process: its live threads, and the threads that already exited.
    static func cpuSeconds() -> Double {
        var basic = mach_task_basic_info()
        var basicCount = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
        let basicResult = withUnsafeMutablePointer(to: &basic) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(basicCount)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &basicCount)
            }
        }
        var threads = task_thread_times_info()
        var threadsCount = mach_msg_type_number_t(MemoryLayout<task_thread_times_info>.size / MemoryLayout<natural_t>.size)
        let threadsResult = withUnsafeMutablePointer(to: &threads) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadsCount)) {
                task_info(mach_task_self_, task_flavor_t(TASK_THREAD_TIMES_INFO), $0, &threadsCount)
            }
        }
        guard basicResult == KERN_SUCCESS, threadsResult == KERN_SUCCESS else { return 0 }
        return seconds(basic.user_time) + seconds(basic.system_time) + seconds(threads.user_time) + seconds(threads.system_time)
    }

    private static func seconds(_ time: time_value_t) -> Double {
        Double(time.seconds) + Double(time.microseconds) / 1_000_000
    }
}

/// Counts the audience window's display refreshes that reach the main thread, so a busy main thread shows up as a lower rate.
/// A display link ticks whether or not SwiftUI drew a frame, so this is the refresh rate, not frames rendered.
private final class FrameCounter: NSObject {
    private var link: CADisplayLink?
    private var frames = 0

    init(window: NSWindow) {
        super.init()
        link = window.displayLink(target: self, selector: #selector(tick))
        link?.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ link: CADisplayLink) {
        frames += 1
    }

    func drain() -> Int {
        defer { frames = 0 }
        return frames
    }

    func stop() {
        link?.invalidate()
    }
}
