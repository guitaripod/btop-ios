import ActivityKit
import SwiftUI
import WidgetKit

struct SystemMetricsLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SystemMetricsAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    expandedLeading(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    expandedTrailing(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedBottom(context: context)
                }
            } compactLeading: {
                compactMetricView(
                    metric: context.attributes.compactLeading,
                    state: context.state
                )
            } compactTrailing: {
                compactMetricView(
                    metric: context.attributes.compactTrailing,
                    state: context.state
                )
            } minimal: {
                Text("\(Int(context.state.cpuPercent))")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(WidgetTheme.color(forPercent: context.state.cpuPercent))
            }
        }
    }

    // MARK: - Compact

    @ViewBuilder
    private func compactMetricView(
        metric: SystemMetricsAttributes.CompactMetric,
        state: SystemMetricsAttributes.ContentState
    ) -> some View {
        switch metric {
        case .cpu:
            Text("CPU \(Int(state.cpuPercent))%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetTheme.color(forPercent: state.cpuPercent))
        case .memory:
            Text("MEM \(Int(state.memoryPercent))%")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetTheme.color(forPercent: state.memoryPercent))
        case .battery:
            HStack(spacing: 2) {
                Text("BAT \(Int(state.batteryLevel * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(WidgetTheme.color(forBattery: state.batteryLevel))
                if state.batteryCharging {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(WidgetTheme.yellow)
                }
            }
        case .network:
            Text("▼\(WidgetTheme.compactRate(state.netRateIn))")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetTheme.netIn)
        case .thermal:
            Text("THM \(WidgetTheme.shortThermal(state.thermalState))")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetTheme.color(forThermal: state.thermalState))
        }
    }

    // MARK: - Expanded

    @ViewBuilder
    private func expandedLeading(context: ActivityViewContext<SystemMetricsAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("CPU")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(WidgetTheme.cyan)
            Text("\(Int(context.state.cpuPercent))%")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetTheme.color(forPercent: context.state.cpuPercent))
        }
    }

    @ViewBuilder
    private func expandedTrailing(context: ActivityViewContext<SystemMetricsAttributes>) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("MEM")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(WidgetTheme.blue)
            Text("\(Int(context.state.memoryPercent))%")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetTheme.color(forPercent: context.state.memoryPercent))
        }
    }

    @ViewBuilder
    private func expandedBottom(context: ActivityViewContext<SystemMetricsAttributes>) -> some View {
        let state = context.state
        VStack(spacing: 4) {
            HStack {
                Text("\(WidgetTheme.rateString(state.netRateIn))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(WidgetTheme.netIn)
                Spacer()
                Text("\(WidgetTheme.rateString(state.netRateOut))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(WidgetTheme.netOut)
            }
            HStack {
                batteryCompact(state: state)
                Spacer()
                Text("THM \(state.thermalState)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(WidgetTheme.color(forThermal: state.thermalState))
                Spacer()
                Text("DSK \(Int(state.storagePercent))%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(WidgetTheme.color(forPercent: state.storagePercent))
            }
        }
    }

    @ViewBuilder
    private func batteryCompact(state: SystemMetricsAttributes.ContentState) -> some View {
        HStack(spacing: 2) {
            Text("BAT \(Int(state.batteryLevel * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(WidgetTheme.color(forBattery: state.batteryLevel))
            if state.batteryCharging {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(WidgetTheme.yellow)
            }
        }
    }

    // MARK: - Lock Screen

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<SystemMetricsAttributes>) -> some View {
        let state = context.state
        VStack(spacing: 4) {
            HStack {
                Text("CPU  \(Int(state.cpuPercent))%")
                    .foregroundStyle(WidgetTheme.color(forPercent: state.cpuPercent))
                Spacer()
                Text("MEM  \(Int(state.memoryPercent))%")
                    .foregroundStyle(WidgetTheme.color(forPercent: state.memoryPercent))
            }
            HStack {
                Text("\(WidgetTheme.rateString(state.netRateIn))")
                    .foregroundStyle(WidgetTheme.netIn)
                Spacer()
                Text("\(WidgetTheme.rateString(state.netRateOut))")
                    .foregroundStyle(WidgetTheme.netOut)
            }
            HStack {
                HStack(spacing: 2) {
                    Text("BAT  \(Int(state.batteryLevel * 100))%")
                        .foregroundStyle(WidgetTheme.color(forBattery: state.batteryLevel))
                    if state.batteryCharging {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(WidgetTheme.yellow)
                    }
                }
                Spacer()
                Text("DSK  \(Int(state.storagePercent))%")
                    .foregroundStyle(WidgetTheme.color(forPercent: state.storagePercent))
            }
            HStack {
                Text("THM  \(state.thermalState)")
                    .foregroundStyle(WidgetTheme.color(forThermal: state.thermalState))
                Spacer()
            }
        }
        .font(.system(size: 12, weight: .bold, design: .monospaced))
        .padding(12)
        .background(Color(red: 0.071, green: 0.071, blue: 0.098))
    }
}

// MARK: - Widget Theme

enum WidgetTheme {

    static let green = Color(red: 0.302, green: 0.851, blue: 0.447)
    static let yellow = Color(red: 0.949, green: 0.800, blue: 0.251)
    static let red = Color(red: 1.000, green: 0.420, blue: 0.420)
    static let blue = Color(red: 0.349, green: 0.651, blue: 0.949)
    static let cyan = Color(red: 0.349, green: 0.749, blue: 0.949)
    static let netIn = Color(red: 0.302, green: 0.851, blue: 0.447)
    static let netOut = Color(red: 0.949, green: 0.549, blue: 0.188)

    static func color(forPercent percent: Double) -> Color {
        if percent > 85 { return red }
        if percent > 60 { return yellow }
        return green
    }

    static func color(forBattery level: Float) -> Color {
        if level < 0.20 { return red }
        if level < 0.50 { return yellow }
        return green
    }

    static func color(forThermal state: String) -> Color {
        switch state {
        case "Nominal": return green
        case "Fair": return yellow
        default: return red
        }
    }

    static func shortThermal(_ state: String) -> String {
        switch state {
        case "Nominal": return "OK"
        case "Fair": return "Fair"
        case "Serious": return "Hot!"
        case "Critical": return "CRIT"
        default: return state
        }
    }

    static func compactRate(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_000_000_000 {
            return String(format: "%.0fG", bytesPerSec / 1_000_000_000)
        } else if bytesPerSec >= 1_000_000 {
            return String(format: "%.0fM", bytesPerSec / 1_000_000)
        } else if bytesPerSec >= 1_000 {
            return String(format: "%.0fK", bytesPerSec / 1_000)
        } else {
            return String(format: "%.0fB", bytesPerSec)
        }
    }

    static func rateString(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_000_000_000 {
            return String(format: "%.1f GB/s", bytesPerSec / 1_000_000_000)
        } else if bytesPerSec >= 1_000_000 {
            return String(format: "%.1f MB/s", bytesPerSec / 1_000_000)
        } else if bytesPerSec >= 1_000 {
            return String(format: "%.1f KB/s", bytesPerSec / 1_000)
        } else {
            return String(format: "%.0f B/s", bytesPerSec)
        }
    }
}
