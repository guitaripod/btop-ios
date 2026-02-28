import UIKit

nonisolated final class BatteryCollector: Sendable {

    private let isSimulator: Bool

    init() {
        #if targetEnvironment(simulator)
        isSimulator = true
        #else
        isSimulator = false
        #endif
    }

    @MainActor
    func collect() -> BatterySnapshot {
        let device = UIDevice.current
        if !device.isBatteryMonitoringEnabled {
            device.isBatteryMonitoringEnabled = true
        }

        let level = device.batteryLevel
        let state: BatterySnapshot.State

        switch device.batteryState {
        case .charging: state = .charging
        case .full: state = .full
        case .unplugged: state = .unplugged
        default: state = .unknown
        }

        return BatterySnapshot(level: level, state: state, isSimulator: isSimulator)
    }
}
