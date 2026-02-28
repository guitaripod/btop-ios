import Foundation

struct SystemSnapshot: Sendable {
    let timestamp: Date
    let cpu: CPUSnapshot
    let memory: MemorySnapshot
    let storage: StorageSnapshot
    let network: NetworkSnapshot
    let battery: BatterySnapshot
    let thermal: ThermalSnapshot
    let device: DeviceSnapshot
    let process: ProcessSnapshot
}

struct CPUSnapshot: Sendable {
    let usagePercent: Double
    let userPercent: Double
    let systemPercent: Double
    let idlePercent: Double
    let nicePercent: Double
    let coreCount: Int
    let history: [Double]
}

struct MemorySnapshot: Sendable {
    let totalBytes: UInt64
    let usedBytes: UInt64
    let activeBytes: UInt64
    let wiredBytes: UInt64
    let compressedBytes: UInt64
    let freeBytes: UInt64
    let inactiveBytes: UInt64
    let appFootprintBytes: UInt64
    let usagePercent: Double
}

struct StorageSnapshot: Sendable {
    let totalBytes: UInt64
    let usedBytes: UInt64
    let availableBytes: UInt64
    let usagePercent: Double
}

struct NetworkSnapshot: Sendable {
    let interfaces: [InterfaceSnapshot]
    let totalRateIn: Double
    let totalRateOut: Double
}

struct InterfaceSnapshot: Sendable {
    let name: String
    let displayName: String
    let ipv4Address: String?
    let ipv6Address: String?
    let bytesIn: UInt64
    let bytesOut: UInt64
    let rateIn: Double
    let rateOut: Double
    let cumulativeIn: UInt64
    let cumulativeOut: UInt64
    let historyIn: [Double]
    let historyOut: [Double]
}

struct BatterySnapshot: Sendable {
    let level: Float
    let state: State
    let isSimulator: Bool

    enum State: String, Sendable {
        case unknown = "Unknown"
        case unplugged = "Unplugged"
        case charging = "Charging"
        case full = "Full"
    }
}

struct ThermalSnapshot: Sendable {
    let state: State

    enum State: String, Sendable {
        case nominal = "Nominal"
        case fair = "Fair"
        case serious = "Serious"
        case critical = "Critical"
    }
}

struct DeviceSnapshot: Sendable {
    let modelIdentifier: String
    let modelName: String
    let osVersion: String
    let deviceName: String
    let uptimeSeconds: TimeInterval
    let currentTime: Date
    let screenWidth: Int
    let screenHeight: Int
    let screenScale: Int
    let maxFPS: Int
    let brightness: Double
    let isLowPowerMode: Bool
    let biometricType: String
    let locale: String
    let timeZone: String
}

struct ProcessSnapshot: Sendable {
    let threadCount: Int
    let cpuUsage: Double
    let memoryFootprint: UInt64
}

nonisolated
struct RingBuffer<T: Sendable>: Sendable {
    private var storage: [T]
    private var index: Int = 0
    private var filled: Bool = false
    let capacity: Int

    init(capacity: Int, defaultValue: T) {
        self.capacity = capacity
        self.storage = Array(repeating: defaultValue, count: capacity)
    }

    mutating func append(_ value: T) {
        storage[index] = value
        index += 1
        if index >= capacity {
            index = 0
            filled = true
        }
    }

    func toArray() -> [T] {
        if !filled {
            return Array(storage[0..<index])
        }
        return Array(storage[index..<capacity]) + Array(storage[0..<index])
    }

    var count: Int {
        filled ? capacity : index
    }

    mutating func trimTo(_ newCapacity: Int) {
        guard newCapacity < capacity else { return }
        let arr = toArray()
        let trimmed = arr.suffix(newCapacity)
        storage = Array(trimmed)
        while storage.count < newCapacity {
            storage.append(storage.last!)
        }
        index = trimmed.count >= newCapacity ? 0 : trimmed.count
        filled = trimmed.count >= newCapacity
    }
}
