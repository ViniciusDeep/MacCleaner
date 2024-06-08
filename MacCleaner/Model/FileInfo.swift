//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import Foundation

struct FileDetail: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let modificationDate: Date
    let path: String
}


func findLargeAndOldFiles(in directory: String, largerThan size: Int64, olderThan days: Int) -> [FileDetail] {
    let fileManager = FileManager.default
    let keys: [URLResourceKey] = [.nameKey, .isRegularFileKey, .fileSizeKey, .contentModificationDateKey]
    let url = URL(fileURLWithPath: directory)

    guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: keys) else {
        print("Failed to create enumerator for directory: \(directory)")
        return []
    }

    var results: [FileDetail] = []

    for case let fileURL as URL in enumerator {
        do {
            let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))

            guard let isRegularFile = resourceValues.isRegularFile, isRegularFile,
                  let fileSize = resourceValues.fileSize,
                  let modificationDate = resourceValues.contentModificationDate else {
                print("Skipping file: \(fileURL.path)")
                continue
            }

            let age = Calendar.current.dateComponents([.day], from: modificationDate, to: Date()).day ?? 0

            print("Found file: \(fileURL.path), Size: \(fileSize), Age: \(age) days")

            if fileSize > size && age > days {
                let fileDetail = FileDetail(
                    name: resourceValues.name ?? fileURL.lastPathComponent,
                    size: Int64(fileSize),
                    modificationDate: modificationDate,
                    path: fileURL.path
                )
                results.append(fileDetail)
            }
        } catch {
            print("Error reading file attributes: \(error.localizedDescription)")
        }
    }

    return results
}



