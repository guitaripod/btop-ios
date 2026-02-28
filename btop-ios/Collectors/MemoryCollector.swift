import Foundation

nonisolated final class MemoryCollector: Sendable {

    private let pageSize: UInt64

    init() {
        var size = vm_size_t(0)
        host_page_size(mach_host_self(), &size)
        pageSize = UInt64(size)
    }

    func collect() -> MemorySnapshot {
        let totalBytes = UInt64(ProcessInfo.processInfo.physicalMemory)

        var vmInfo = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let vmResult = withUnsafeMutablePointer(to: &vmInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        var appFootprint: UInt64 = 0
        var taskInfo = task_vm_info_data_t()
        var taskCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)

        let taskResult = withUnsafeMutablePointer(to: &taskInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(taskCount)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &taskCount)
            }
        }

        if taskResult == KERN_SUCCESS {
            appFootprint = UInt64(taskInfo.phys_footprint)
        }

        guard vmResult == KERN_SUCCESS else {
            return MemorySnapshot(
                totalBytes: totalBytes, usedBytes: 0, activeBytes: 0,
                wiredBytes: 0, compressedBytes: 0, freeBytes: totalBytes,
                inactiveBytes: 0, appFootprintBytes: appFootprint, usagePercent: 0
            )
        }

        let active = UInt64(vmInfo.active_count) * pageSize
        let wired = UInt64(vmInfo.wire_count) * pageSize
        let compressed = UInt64(vmInfo.compressor_page_count) * pageSize
        let inactive = UInt64(vmInfo.inactive_count) * pageSize
        let free = UInt64(vmInfo.free_count) * pageSize
        let used = active + wired + compressed
        let usagePercent = totalBytes > 0 ? (Double(used) / Double(totalBytes)) * 100 : 0

        return MemorySnapshot(
            totalBytes: totalBytes, usedBytes: used, activeBytes: active,
            wiredBytes: wired, compressedBytes: compressed, freeBytes: free,
            inactiveBytes: inactive, appFootprintBytes: appFootprint,
            usagePercent: usagePercent
        )
    }
}
