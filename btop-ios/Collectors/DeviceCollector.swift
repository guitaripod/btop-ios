import UIKit
import LocalAuthentication

nonisolated final class DeviceCollector: @unchecked Sendable {

    private var staticInfo: StaticInfo?
    private weak var windowScene: UIWindowScene?

    nonisolated init() {}

    @MainActor
    func collect(scene: UIWindowScene?) -> DeviceSnapshot {
        if windowScene == nil { windowScene = scene }
        let activeScene = windowScene ?? scene

        let info: StaticInfo
        if let existing = staticInfo {
            info = existing
        } else {
            info = StaticInfo(scene: activeScene)
            staticInfo = info
        }

        var brightness: Double = 0.5
        if let screen = activeScene?.screen {
            brightness = Double(screen.brightness)
        }

        return DeviceSnapshot(
            modelIdentifier: info.modelIdentifier,
            modelName: info.modelName,
            osVersion: info.osVersion,
            deviceName: info.deviceName,
            uptimeSeconds: ProcessInfo.processInfo.systemUptime,
            currentTime: Date(),
            screenWidth: info.screenWidth,
            screenHeight: info.screenHeight,
            screenScale: info.screenScale,
            maxFPS: info.maxFPS,
            brightness: brightness,
            isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
            biometricType: info.biometricType,
            locale: info.locale,
            timeZone: info.timeZoneStr
        )
    }
}

private struct StaticInfo: Sendable {
    let modelIdentifier: String
    let modelName: String
    let osVersion: String
    let deviceName: String
    let screenWidth: Int
    let screenHeight: Int
    let screenScale: Int
    let maxFPS: Int
    let biometricType: String
    let locale: String
    let timeZoneStr: String

    @MainActor
    init(scene: UIWindowScene?) {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 256) {
                String(cString: $0)
            }
        }

        modelIdentifier = machine
        modelName = Self.modelName(for: machine)

        let v = ProcessInfo.processInfo.operatingSystemVersion
        osVersion = "iOS \(v.majorVersion).\(v.minorVersion)"
        deviceName = UIDevice.current.name

        if let screen = scene?.screen {
            let bounds = screen.bounds
            screenWidth = Int(bounds.width * screen.scale)
            screenHeight = Int(bounds.height * screen.scale)
            screenScale = Int(screen.scale)
            maxFPS = screen.maximumFramesPerSecond
        } else {
            screenWidth = 0
            screenHeight = 0
            screenScale = 0
            maxFPS = 60
        }

        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .none: biometricType = "None"
            case .faceID: biometricType = "Face ID"
            case .touchID: biometricType = "Touch ID"
            case .opticID: biometricType = "Optic ID"
            @unknown default: biometricType = "Biometric"
            }
        } else {
            biometricType = "None"
        }

        locale = Locale.current.identifier
        let tz = TimeZone.current
        let offset = tz.secondsFromGMT() / 3600
        let sign = offset >= 0 ? "+" : ""
        timeZoneStr = "\(tz.abbreviation() ?? "??") (UTC\(sign)\(offset))"
    }

    nonisolated private static func modelName(for identifier: String) -> String {
        let map: [String: String] = [
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,5": "iPhone 16e",
            "iPhone18,1": "iPhone 17 Air",
            "iPhone18,2": "iPhone 17 Pro",
            "iPhone18,3": "iPhone 17 Pro Max",
            "iPhone18,4": "iPhone 17",
            "iPhone14,6": "iPhone SE 3rd Gen",
            "iPhone12,8": "iPhone SE 2nd Gen",
            "iPad13,16": "iPad Air 5th Gen",
            "iPad13,17": "iPad Air 5th Gen",
            "iPad14,3": "iPad Pro 11\" M2",
            "iPad14,4": "iPad Pro 11\" M2",
            "iPad14,5": "iPad Pro 12.9\" M2",
            "iPad14,6": "iPad Pro 12.9\" M2",
            "iPad14,8": "iPad Air M2 11\"",
            "iPad14,9": "iPad Air M2 11\"",
            "iPad14,10": "iPad Air M2 13\"",
            "iPad14,11": "iPad Air M2 13\"",
            "iPad16,3": "iPad Pro M4 11\"",
            "iPad16,4": "iPad Pro M4 11\"",
            "iPad16,5": "iPad Pro M4 13\"",
            "iPad16,6": "iPad Pro M4 13\"",
            "iPad14,1": "iPad Mini 6th Gen",
            "iPad14,2": "iPad Mini 6th Gen",
            "iPad13,18": "iPad 10th Gen",
            "iPad13,19": "iPad 10th Gen",
        ]

        if let name = map[identifier] { return name }

        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        return identifier
        #endif
    }
}
