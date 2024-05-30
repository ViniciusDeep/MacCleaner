//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import Foundation

struct StorageInfo {
    var totalSpace: Int64
    var freeSpace: Int64
    var usedSpace: Int64
}

func getStorageInfo() -> StorageInfo? {
    if let homeDirectory = try? FileManager.default.url(
        for: .userDirectory,
        in: .localDomainMask,
        appropriateFor: nil,
        create: false
    ) {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: homeDirectory.path)
            if let totalSpace = attributes[.systemSize] as? Int64,
               let freeSpace = attributes[.systemFreeSize] as? Int64
            {
                let usedSpace = totalSpace - freeSpace
                return StorageInfo(totalSpace: totalSpace, freeSpace: freeSpace, usedSpace: usedSpace)
            }
        } catch {
            print("Error retrieving storage information: \(error.localizedDescription)")
        }
    }
    return nil
}
