import Foundation

final class Settings {

    static let shared = Settings()

    enum RefreshRate: Double, CaseIterable {
        case hz1 = 1.0
        case hz2 = 0.5
        case hz5 = 0.2
        case hz10 = 0.1

        var label: String {
            switch self {
            case .hz1: "1 Hz"
            case .hz2: "2 Hz"
            case .hz5: "5 Hz"
            case .hz10: "10 Hz"
            }
        }
    }

    enum GraphHeight: CGFloat, CaseIterable {
        case compact = 32
        case normal = 48
        case tall = 64

        var label: String {
            switch self {
            case .compact: "Compact"
            case .normal: "Normal"
            case .tall: "Tall"
            }
        }
    }

    enum Section: String, CaseIterable {
        case device, cpu, memory, storage, network, battery, thermal, process

        var label: String {
            switch self {
            case .cpu: "CPU"
            default: rawValue.prefix(1).uppercased() + rawValue.dropFirst()
            }
        }
    }

    private let defaults = UserDefaults.standard

    var refreshRate: RefreshRate {
        get {
            let val = defaults.double(forKey: "refreshRate")
            return RefreshRate(rawValue: val) ?? .hz10
        }
        set { defaults.set(newValue.rawValue, forKey: "refreshRate") }
    }

    var keepScreenOn: Bool {
        get {
            if defaults.object(forKey: "keepScreenOn") == nil { return true }
            return defaults.bool(forKey: "keepScreenOn")
        }
        set { defaults.set(newValue, forKey: "keepScreenOn") }
    }

    var graphHeight: GraphHeight {
        get {
            let val = defaults.double(forKey: "graphHeight")
            return GraphHeight(rawValue: val) ?? .normal
        }
        set { defaults.set(newValue.rawValue, forKey: "graphHeight") }
    }

    func isSectionVisible(_ section: Section) -> Bool {
        if defaults.object(forKey: "section.\(section.rawValue)") == nil { return true }
        return defaults.bool(forKey: "section.\(section.rawValue)")
    }

    func setSectionVisible(_ section: Section, visible: Bool) {
        defaults.set(visible, forKey: "section.\(section.rawValue)")
    }

    private init() {}
}
