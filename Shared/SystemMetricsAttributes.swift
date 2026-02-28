import ActivityKit
import Foundation

struct SystemMetricsAttributes: ActivityAttributes {

    enum CompactMetric: String, Codable, CaseIterable {
        case cpu = "CPU"
        case memory = "MEM"
        case battery = "BAT"
        case network = "NET"
        case thermal = "THM"
    }

    var compactLeading: CompactMetric
    var compactTrailing: CompactMetric

    struct ContentState: Codable, Hashable {
        var cpuPercent: Double
        var memoryPercent: Double
        var batteryLevel: Float
        var batteryCharging: Bool
        var netRateIn: Double
        var netRateOut: Double
        var thermalState: String
        var storagePercent: Double
    }
}
