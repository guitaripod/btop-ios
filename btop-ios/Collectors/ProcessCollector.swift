import Foundation

nonisolated final class ProcessCollector: @unchecked Sendable {

    private var prevUserTime: Double = 0
    private var prevSystemTime: Double = 0
    private var firstPoll = true

    nonisolated init() {}

    func collect(elapsed: TimeInterval) -> ProcessSnapshot {
        var basicInfo = mach_task_basic_info_data_t()
        var basicCount = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)

        let basicResult = withUnsafeMutablePointer(to: &basicInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(basicCount)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), intPtr, &basicCount)
            }
        }

        var threadCount = 0
        var cpuUsage: Double = 0

        if basicResult == KERN_SUCCESS {
            let userSec = Double(basicInfo.user_time.seconds) + Double(basicInfo.user_time.microseconds) / 1_000_000
            let sysSec = Double(basicInfo.system_time.seconds) + Double(basicInfo.system_time.microseconds) / 1_000_000

            if firstPoll {
                prevUserTime = userSec
                prevSystemTime = sysSec
                firstPoll = false
            } else {
                let dt = max(elapsed, 0.001)
                let deltaUser = userSec - prevUserTime
                let deltaSys = sysSec - prevSystemTime
                cpuUsage = ((deltaUser + deltaSys) / dt) * 100
                prevUserTime = userSec
                prevSystemTime = sysSec
            }
        }

        var taskInfo = task_vm_info_data_t()
        var taskCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)

        var memFootprint: UInt64 = 0

        let vmResult = withUnsafeMutablePointer(to: &taskInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(taskCount)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &taskCount)
            }
        }

        if vmResult == KERN_SUCCESS {
            memFootprint = UInt64(taskInfo.phys_footprint)
        }

        var threadList: thread_act_array_t?
        var threadListCount: mach_msg_type_number_t = 0
        let threadResult = task_threads(mach_task_self_, &threadList, &threadListCount)
        if threadResult == KERN_SUCCESS {
            threadCount = Int(threadListCount)
            if let list = threadList {
                for i in 0..<Int(threadListCount) {
                    mach_port_deallocate(mach_task_self_, list[i])
                }
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: list), vm_size_t(Int(threadListCount) * MemoryLayout<thread_act_t>.size))
            }
        }

        return ProcessSnapshot(
            threadCount: threadCount,
            cpuUsage: max(cpuUsage, 0),
            memoryFootprint: memFootprint
        )
    }
}
