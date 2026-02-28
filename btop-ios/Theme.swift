import UIKit

enum Theme {

    static let background = UIColor(red: 0.071, green: 0.071, blue: 0.098, alpha: 1)
    static let sectionBackground = UIColor(red: 0.102, green: 0.102, blue: 0.141, alpha: 1)
    static let border = UIColor(red: 0.165, green: 0.165, blue: 0.227, alpha: 1)

    static let textPrimary = UIColor(red: 0.851, green: 0.851, blue: 0.902, alpha: 1)
    static let textSecondary = UIColor(red: 0.502, green: 0.502, blue: 0.549, alpha: 1)
    static let label = UIColor(red: 0.400, green: 0.451, blue: 0.533, alpha: 1)

    static let green = UIColor(red: 0.302, green: 0.851, blue: 0.447, alpha: 1)
    static let yellow = UIColor(red: 0.949, green: 0.800, blue: 0.251, alpha: 1)
    static let red = UIColor(red: 1.000, green: 0.420, blue: 0.420, alpha: 1)
    static let blue = UIColor(red: 0.349, green: 0.651, blue: 0.949, alpha: 1)
    static let cyan = UIColor(red: 0.349, green: 0.749, blue: 0.949, alpha: 1)

    static let netIn = UIColor(red: 0.302, green: 0.851, blue: 0.447, alpha: 1)
    static let netOut = UIColor(red: 0.949, green: 0.549, blue: 0.188, alpha: 1)

    static let memActive = UIColor(red: 0.349, green: 0.651, blue: 0.949, alpha: 1)
    static let memWired = UIColor(red: 0.949, green: 0.800, blue: 0.251, alpha: 1)
    static let memCompressed = UIColor(red: 0.722, green: 0.451, blue: 0.949, alpha: 1)

    static let font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    static let fontBold = UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
    static let fontHeader = UIFont.monospacedSystemFont(ofSize: 12, weight: .bold)
    static let fontSmall = UIFont.monospacedSystemFont(ofSize: 9, weight: .regular)

    static let sectionSpacing: CGFloat = 4
    static let padding: CGFloat = 8
    static let rowHeight: CGFloat = 16
    static let graphHeight: CGFloat = 48
    static let barHeight: CGFloat = 12

    static func color(forPercent percent: Double) -> UIColor {
        if percent > 85 { return red }
        if percent > 60 { return yellow }
        return green
    }

    static func color(forThermal state: ThermalSnapshot.State) -> UIColor {
        switch state {
        case .nominal: return green
        case .fair: return yellow
        case .serious, .critical: return red
        }
    }

    static func color(forBattery level: Float) -> UIColor {
        if level < 0.20 { return red }
        if level < 0.50 { return yellow }
        return green
    }
}
