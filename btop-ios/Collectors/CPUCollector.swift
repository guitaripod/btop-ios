import Foundation

nonisolated final class CPUCollector: @unchecked Sendable {

    private var prevUser: UInt32 = 0
    private var prevSystem: UInt32 = 0
    private var prevIdle: UInt32 = 0
    private var prevNice: UInt32 = 0
    private var firstPoll = true
    private var history = RingBuffer<Double>(capacity: 60, defaultValue: 0)
    private let coreCount: Int

    nonisolated init() {
        coreCount = ProcessInfo.processInfo.processorCount
    }

    func collect() -> CPUSnapshot {
        var loadInfo = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &loadInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, intPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return CPUSnapshot(
                usagePercent: 0, userPercent: 0, systemPercent: 0,
                idlePercent: 100, nicePercent: 0, coreCount: coreCount,
                history: history.toArray()
            )
        }

        let user = loadInfo.cpu_ticks.0
        let system = loadInfo.cpu_ticks.1
        let idle = loadInfo.cpu_ticks.2
        let nice = loadInfo.cpu_ticks.3

        if firstPoll {
            prevUser = user
            prevSystem = system
            prevIdle = idle
            prevNice = nice
            firstPoll = false
            history.append(0)
            return CPUSnapshot(
                usagePercent: 0, userPercent: 0, systemPercent: 0,
                idlePercent: 100, nicePercent: 0, coreCount: coreCount,
                history: history.toArray()
            )
        }

        let dUser = Double(user &- prevUser)
        let dSystem = Double(system &- prevSystem)
        let dIdle = Double(idle &- prevIdle)
        let dNice = Double(nice &- prevNice)
        let total = max(dUser + dSystem + dIdle + dNice, 1)

        prevUser = user
        prevSystem = system
        prevIdle = idle
        prevNice = nice

        let usage = ((dUser + dSystem + dNice) / total) * 100
        let userPct = (dUser / total) * 100
        let systemPct = (dSystem / total) * 100
        let idlePct = (dIdle / total) * 100
        let nicePct = (dNice / total) * 100

        history.append(usage)

        return CPUSnapshot(
            usagePercent: usage, userPercent: userPct, systemPercent: systemPct,
            idlePercent: idlePct, nicePercent: nicePct, coreCount: coreCount,
            history: history.toArray()
        )
    }

    func trimHistory() {
        history.trimTo(30)
    }
}
