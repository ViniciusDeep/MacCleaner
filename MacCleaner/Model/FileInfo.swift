//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import Foundation

struct FileDetail: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let modificationDate: Date
}

func findLargeAndOldFiles(in directory: String, largerThan size: Int64, olderThan days: Int) -> [FileDetail] {
    var results = [FileDetail]()
    let fileManager = FileManager.default
    let calendar = Calendar.current
    let dateThreshold = calendar.date(byAdding: .day, value: -days, to: Date())!

    do {
        let urls = try fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: directory),
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        )

        for url in urls {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            if let fileSize = resourceValues.fileSize, let modificationDate = resourceValues.contentModificationDate {
                if fileSize > size, modificationDate < dateThreshold {
                    results.append(FileDetail(
                        name: url.lastPathComponent,
                        size: Int64(fileSize),
                        modificationDate: modificationDate
                    ))
                }
            }
        }
    } catch {
        print("Error while enumerating files \(directory): \(error.localizedDescription)")
    }

    return results
}
