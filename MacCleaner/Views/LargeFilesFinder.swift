import SwiftUI

struct LargeFilesFinder: View {
    @State private var largeFiles: [FileDetail] = []
    @State private var scanCompleted = false
    @State private var progress: Double = 0.0
    @State private var totalFiles: Int = 0
    @State private var scannedFiles: Int = 0

    var body: some View {
        VStack {
            Text("Large & Old Files")
                .font(.largeTitle)
                .padding()

            Spacer()

            if scanCompleted {
                if largeFiles.isEmpty {
                    Text("No large or old files found")
                        .padding()
                } else {
                    List(largeFiles) { file in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.headline)
                                Text("Size: \(formatBytes(file.size))")
                                Text("Modified: \(formatDate(file.modificationDate))")
                            }
                            Spacer()
                            Button(action: {
                                deleteFile(at: file.path)
                            }) {
                                Text("Delete")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Text("Scanning for large and old files...")
                        .padding()
                    
                    ProgressView(value: progress, total: Double(totalFiles))
                        .padding()
                    
                    Text("Scanned \(scannedFiles) files")
                        .padding()
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                scanForLargeFiles()
            }
        }
    }

    private func scanForLargeFiles() {
        let directory = "/"
        guard let allFiles = getAllFiles(in: directory) else {
            DispatchQueue.main.async {
                scanCompleted = true
            }
            return
        }
        
        totalFiles = allFiles.count
        
        let files = findLargeAndOldFiles(
            in: allFiles,
            largerThan: 50 * 1024 * 1024, // 50 MB
            olderThan: 30 // 30 days
        )

        DispatchQueue.main.async {
            largeFiles = files
            scanCompleted = true
        }
    }

    private func getAllFiles(in directory: String) -> [URL]? {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: directory)
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            print("Failed to create enumerator for directory: \(directory)")
            return nil
        }

        var allFiles: [URL] = []
        for case let fileURL as URL in enumerator {
            allFiles.append(fileURL)
            scannedFiles += 1
            progress = Double(scannedFiles) / Double(totalFiles)
        }
        return allFiles
    }

    private func findLargeAndOldFiles(in files: [URL], largerThan size: Int64, olderThan days: Int) -> [FileDetail] {
        var results: [FileDetail] = []
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.nameKey, .isRegularFileKey, .fileSizeKey, .contentModificationDateKey]

        for fileURL in files {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))

                guard let isRegularFile = resourceValues.isRegularFile, isRegularFile,
                      let fileSize = resourceValues.fileSize,
                      let modificationDate = resourceValues.contentModificationDate else {
                    continue
                }

                let age = Calendar.current.dateComponents([.day], from: modificationDate, to: Date()).day ?? 0

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

            DispatchQueue.main.async {
                scannedFiles += 1
                progress = Double(scannedFiles) / Double(totalFiles)
            }
        }

        return results
    }

    private func deleteFile(at path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
            largeFiles.removeAll { $0.path == path }
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
