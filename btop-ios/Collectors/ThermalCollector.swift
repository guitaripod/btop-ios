import Foundation

nonisolated final class ThermalCollector: Sendable {

    func collect() -> ThermalSnapshot {
        let state: ThermalSnapshot.State
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: state = .nominal
        case .fair: state = .fair
        case .serious: state = .serious
        case .critical: state = .critical
        @unknown default: state = .nominal
        }
        return ThermalSnapshot(state: state)
    }
}
