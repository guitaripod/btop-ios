import ActivityKit
import Foundation

final class ActivityManager {

    static let shared = ActivityManager()

    var isActive: Bool { currentActivity != nil }

    private var currentActivity: Activity<SystemMetricsAttributes>?
    private var lastUpdate: Date = .distantPast
    private let throttleInterval: TimeInterval = 0.5
    private var observationTask: Task<Void, Never>?

    private init() {}

    func start() {
        guard Settings.shared.liveActivityEnabled else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        if let existing = currentActivity {
            if existing.activityState == .active { return }
            currentActivity = nil
        }

        let attributes = SystemMetricsAttributes(
            compactLeading: Settings.shared.islandLeading,
            compactTrailing: Settings.shared.islandTrailing
        )

        let initialState = SystemMetricsAttributes.ContentState(
            cpuPercent: 0,
            memoryPercent: 0,
            batteryLevel: 1.0,
            batteryCharging: false,
            netRateIn: 0,
            netRateOut: 0,
            thermalState: "Nominal",
            storagePercent: 0
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            observeDismissal(activity)
        } catch {}
    }

    func stop() {
        observationTask?.cancel()
        observationTask = nil
        let activity = currentActivity
        currentActivity = nil
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
        }
    }

    func restart() {
        stop()
        start()
    }

    func update(with snapshot: SystemSnapshot) {
        guard currentActivity != nil else { return }

        let now = Date()
        guard now.timeIntervalSince(lastUpdate) >= throttleInterval else { return }
        lastUpdate = now

        let state = SystemMetricsAttributes.ContentState(
            cpuPercent: snapshot.cpu.usagePercent,
            memoryPercent: snapshot.memory.usagePercent,
            batteryLevel: snapshot.battery.level,
            batteryCharging: snapshot.battery.state == .charging,
            netRateIn: snapshot.network.totalRateIn,
            netRateOut: snapshot.network.totalRateOut,
            thermalState: snapshot.thermal.state.rawValue,
            storagePercent: snapshot.storage.usagePercent
        )

        Task {
            await currentActivity?.update(.init(state: state, staleDate: nil))
        }
    }

    private func observeDismissal(_ activity: Activity<SystemMetricsAttributes>) {
        observationTask?.cancel()
        observationTask = Task {
            for await state in activity.activityStateUpdates {
                if state == .dismissed || state == .ended {
                    currentActivity = nil
                    break
                }
            }
        }
    }
}
