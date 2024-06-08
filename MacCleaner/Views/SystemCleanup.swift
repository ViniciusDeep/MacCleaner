//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

import SwiftUI

struct SystemCleanup: View {
    @State private var showSheet = false
    @State private var cleanupResult = ""
    @State private var showingResult = false
    @State private var progress: Double = 0.0

    var body: some View {
        VStack {
            Text("System Cleanup")
                .font(.largeTitle)
                .padding()

            Spacer()

            Button(action: {
                showSheet = true
            }) {
                Text("Clean My Mac")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(CustomButtonStyle())
            .padding()

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSheet) {
            VStack {
                Text("Confirm Cleanup")
                    .font(.headline)
                    .padding()

                Text("Are you sure you want to clean your Mac? This will delete temporary files, large and old files, and Xcode cache.")
                    .padding()

                HStack {
                    Button(action: {
                        performCleanup()
                        showSheet = false
                    }) {
                        Text("Clean")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        showSheet = false
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .frame(width: 300, height: 200)
        }
        .alert(isPresented: $showingResult) {
            Alert(
                title: Text(cleanupResult),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func performCleanup() {
        DispatchQueue.global(qos: .background).async {
            var result = true

            let cleanupFunctions = [
                performSystemCleanup,
                performLargeFilesCleanup,
                performXcodeCacheCleanup
            ]

            for (index, cleanupFunction) in cleanupFunctions.enumerated() {
                if !cleanupFunction() {
                    result = false
                }
                DispatchQueue.main.async {
                    progress = Double(index + 1) / Double(cleanupFunctions.count)
                }
            }

            DispatchQueue.main.async {
                cleanupResult = result ? "Cleanup Successful!" : "Cleanup Failed!"
                showingResult = true
            }
        }
    }

    private func performSystemCleanup() -> Bool {
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
            print("Error during system cleanup: \(error.localizedDescription)")
            return false
        }
    }

    private func performLargeFilesCleanup() -> Bool {
        let directory = "/"  // Root directory to scan for large files
        guard let allFiles = getAllFiles(in: directory) else {
            return false
        }
        
        let files = findLargeAndOldFiles(
            in: allFiles,
            largerThan: 50 * 1024 * 1024, // 50 MB
            olderThan: 30 // 30 days
        )

        do {
            for file in files {
                try FileManager.default.removeItem(atPath: file.path)
            }
            return true
        } catch {
            print("Error during large files cleanup: \(error.localizedDescription)")
            return false
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
        }

        return results
    }

    private func performXcodeCacheCleanup() -> Bool {
        let xcodeCacheDirectories = [
            NSHomeDirectory().appending("/Library/Developer/Xcode/DerivedData"),
            NSHomeDirectory().appending("/Library/Caches/com.apple.dt.Xcode")
        ]

        do {
            for dir in xcodeCacheDirectories {
                let files = try FileManager.default.contentsOfDirectory(atPath: dir)
                for file in files {
                    let filePath = (dir as NSString).appendingPathComponent(file)
                    try FileManager.default.removeItem(atPath: filePath)
                }
            }
            return true
        } catch {
            print("Error during Xcode cache cleanup: \(error.localizedDescription)")
            return false
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
