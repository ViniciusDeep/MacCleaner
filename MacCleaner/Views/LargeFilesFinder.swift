//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

struct LargeFilesFinder: View {
    @State private var largeFiles: [FileDetail] = []
    @State private var scanCompleted = false

    var body: some View {
        VStack {
            Text("Large & Old Files")
                .font(.largeTitle)
                .padding()

            Spacer()

            if scanCompleted {
                List(largeFiles) { file in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(file.name)
                                .font(.headline)
                            Text("Size: \(formatBytes(file.size))")
                            Text("Modified: \(formatDate(file.modificationDate))")
                        }
                    }
                }
            } else {
                Text("Scanning for large and old files...")
                    .padding()

                Button(action: {
                    scanForLargeFiles()
                }) {
                    Text("Start Scan")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.buttonStyle(CustomButtonStyle())
            }

            Spacer()
        }
        .padding()
    }

    private func scanForLargeFiles() {
        DispatchQueue.global(qos: .background).async {
            let directory = NSHomeDirectory()
            let files = findLargeAndOldFiles(
                in: directory,
                largerThan: 50 * 1024 * 1024,
                olderThan: 30
            )

            DispatchQueue.main.async {
                largeFiles = files
                scanCompleted = true
            }
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
