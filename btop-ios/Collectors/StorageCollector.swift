import Foundation

nonisolated final class StorageCollector: Sendable {

    func collect() -> StorageSnapshot {
        let url = URL(fileURLWithPath: NSHomeDirectory())

        guard let values = try? url.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
        ]) else {
            return StorageSnapshot(totalBytes: 0, usedBytes: 0, availableBytes: 0, usagePercent: 0)
        }

        let total = UInt64(values.volumeTotalCapacity ?? 0)
        let available = UInt64(values.volumeAvailableCapacityForImportantUsage ?? 0)
        let used = total > available ? total - available : 0
        let percent = total > 0 ? (Double(used) / Double(total)) * 100 : 0

        return StorageSnapshot(
            totalBytes: total, usedBytes: used,
            availableBytes: available, usagePercent: percent
        )
    }
}
