//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import Foundation

func performSystemCleanup() -> Bool {
    let tempDirectories = [
        NSTemporaryDirectory(),
        "/var/folders",
    ]

    do {
        for dir in tempDirectories {
            let files = try FileManager.default.contentsOfDirectory(atPath: dir)
            for file in files {
                let filePath = (dir as NSString).appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: filePath)
            }
        }
        return true
    } catch {
        print("Error during cleanup: \(error.localizedDescription)")
        return false
    }
}
