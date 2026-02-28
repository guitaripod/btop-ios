import Foundation
import UIKit

final class SystemCollector {

    private let cpuCollector = CPUCollector()
    private let memoryCollector = MemoryCollector()
    private let storageCollector = StorageCollector()
    private let networkCollector = NetworkCollector()
    private let batteryCollector = BatteryCollector()
    private let thermalCollector = ThermalCollector()
    private let deviceCollector = DeviceCollector()
    private let processCollector = ProcessCollector()

    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "btop.collection", qos: .userInteractive)
    private var tickCount: Int = 0
    private var lastStorage: StorageSnapshot?
    private var lastTimestamp: Date?
    private var onUpdate: ((SystemSnapshot) -> Void)?

    func start(interval: TimeInterval, onUpdate: @escaping (SystemSnapshot) -> Void) {
        if timer != nil { return }
        self.onUpdate = onUpdate
        lastTimestamp = Date()

        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now(), repeating: interval)

        source.setEventHandler { [weak self] in
            self?.tick()
        }

        timer = source
        source.resume()
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func trimHistory() {
        queue.async { [self] in
            cpuCollector.trimHistory()
            networkCollector.trimHistory()
        }
    }

    private func tick() {
        let now = Date()
        let elapsed = lastTimestamp.map { now.timeIntervalSince($0) } ?? 0.1
        lastTimestamp = now

        if elapsed > 0.5 {
            _ = cpuCollector.collect()
            _ = networkCollector.collect(elapsed: elapsed)
            _ = processCollector.collect(elapsed: elapsed)
            return
        }

        var batterySnapshot = BatterySnapshot(level: -1, state: .unknown, isSimulator: true)
        var deviceSnapshot: DeviceSnapshot?

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async { [self] in
            batterySnapshot = batteryCollector.collect()
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            deviceSnapshot = deviceCollector.collect(scene: scene)
            group.leave()
        }
        group.wait()

        let cpu = cpuCollector.collect()
        let memory = memoryCollector.collect()
        let network = networkCollector.collect(elapsed: elapsed)
        let thermal = thermalCollector.collect()
        let process = processCollector.collect(elapsed: elapsed)

        tickCount += 1
        let storage: StorageSnapshot
        if tickCount % 10 == 0 || lastStorage == nil {
            storage = storageCollector.collect()
            lastStorage = storage
        } else {
            storage = lastStorage ?? StorageSnapshot(totalBytes: 0, usedBytes: 0, availableBytes: 0, usagePercent: 0)
        }

        let snapshot = SystemSnapshot(
            timestamp: now,
            cpu: cpu,
            memory: memory,
            storage: storage,
            network: network,
            battery: batterySnapshot,
            thermal: thermal,
            device: deviceSnapshot ?? DeviceSnapshot(
                modelIdentifier: "", modelName: "", osVersion: "", deviceName: "",
                uptimeSeconds: 0, currentTime: now,
                screenWidth: 0, screenHeight: 0, screenScale: 0, maxFPS: 0,
                brightness: 0, isLowPowerMode: false, biometricType: "",
                locale: "", timeZone: ""
            ),
            process: process
        )

        let callback = onUpdate
        DispatchQueue.main.async {
            callback?(snapshot)
        }
    }
}
