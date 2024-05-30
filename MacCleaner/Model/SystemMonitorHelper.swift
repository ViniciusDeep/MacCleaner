//  Copyright © 2023 Wendy's International, LLC. All rights reserved.

import Foundation

class SystemMonitorHelper {
    static func getCPUUsage() -> Double {
        var cpuInfo: processor_info_array_t!
        var numCPUs: mach_msg_type_number_t = 0
        var prevIdleTicks: UInt64 = 0
        var prevTotalTicks: UInt64 = 0

        var numCPUsCopy = numCPUs

        let err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCPUsCopy)
        if err == KERN_SUCCESS {
            let cpuLoadInfo = cpuInfo!
                .withMemoryRebound(to: Int32.self, capacity: Int(numCPUsCopy)) { ptr in
                    ptr
                }
            var totalTicks: UInt64 = 0
            var idleTicks: UInt64 = 0
            for cpu in 0 ..< Int(numCPUsCopy) {
                totalTicks += UInt64(cpuLoadInfo[cpu])
            }
            idleTicks = UInt64(cpuLoadInfo[Int(CPU_STATE_IDLE)])
            let totalTicksDiff = Double(totalTicks - prevTotalTicks)
            let idleTicksDiff = Double(idleTicks - prevIdleTicks)
            let usage = (totalTicksDiff - idleTicksDiff) / totalTicksDiff * 100.0
            prevIdleTicks = idleTicks
            prevTotalTicks = totalTicks
            return usage
        } else {
            print("Error getting CPU usage: \(String(describing: mach_error_string(err)))")
            return 0.0
        }
    }

    static func getMemoryUsage() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        if kerr == KERN_SUCCESS {
            let usedMemory = taskInfo.resident_size
            let totalMemory = ProcessInfo.processInfo.physicalMemory
            return Double(usedMemory) / Double(totalMemory) * 100.0
        } else {
            print("Error getting memory usage: \(String(describing: mach_error_string(kerr)))")
            return 0.0
        }
    }

    static func getDiskUsage() -> Double {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: "/")
            if let totalSize = systemAttributes[.systemSize] as? Int64,
               let freeSize = systemAttributes[.systemFreeSize] as? Int64
            {
                let usedSize = totalSize - freeSize
                return Double(usedSize) / Double(totalSize) * 100.0
            }
        } catch {
            print("Error getting disk usage: \(error.localizedDescription)")
        }
        return 0.0
    }
}
