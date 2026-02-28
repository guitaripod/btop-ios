import Foundation

enum Formatters {

    static func bytes(_ value: UInt64) -> String {
        let d = Double(value)
        if d >= 1_000_000_000_000 {
            return String(format: "%5.1f TB", d / 1_000_000_000_000)
        } else if d >= 1_000_000_000 {
            return String(format: "%5.2f GB", d / 1_000_000_000)
        } else if d >= 1_000_000 {
            return String(format: "%5.1f MB", d / 1_000_000)
        } else if d >= 1_000 {
            return String(format: "%5.1f KB", d / 1_000)
        } else {
            return String(format: "%5.0f  B", d)
        }
    }

    static func bytesCompact(_ value: UInt64) -> String {
        let d = Double(value)
        if d >= 1_000_000_000_000 {
            return String(format: "%.1f TB", d / 1_000_000_000_000)
        } else if d >= 1_000_000_000 {
            return String(format: "%.1f GB", d / 1_000_000_000)
        } else if d >= 10_000_000 {
            return String(format: "%.0f MB", d / 1_000_000)
        } else if d >= 1_000_000 {
            return String(format: "%.1f MB", d / 1_000_000)
        } else if d >= 10_000 {
            return String(format: "%.0f KB", d / 1_000)
        } else if d >= 1_000 {
            return String(format: "%.1f KB", d / 1_000)
        } else {
            return String(format: "%.0f B", d)
        }
    }

    static func rate(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_000_000_000 {
            return String(format: "%5.1f GB/s", bytesPerSec / 1_000_000_000)
        } else if bytesPerSec >= 1_000_000 {
            return String(format: "%5.2f MB/s", bytesPerSec / 1_000_000)
        } else if bytesPerSec >= 1_000 {
            return String(format: "%5.1f KB/s", bytesPerSec / 1_000)
        } else {
            return String(format: "%5.0f  B/s", bytesPerSec)
        }
    }

    static func percent(_ value: Double) -> String {
        return String(format: "%5.1f%%", value)
    }

    static func uptime(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    static func time(_ date: Date) -> String {
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        let s = cal.component(.second, from: date)
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
