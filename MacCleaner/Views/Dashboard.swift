//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

struct Dashboard: View {
    @State private var storageInfo: StorageInfo? = getStorageInfo()
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    @State private var diskUsage: Double = 0.0

    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.largeTitle)
                .padding()

            if let storageInfo = storageInfo {
                VStack(alignment: .leading) {
                    Text("Storage Information")
                        .font(.headline)
                        .padding(.bottom)

                    Text("Total Space: \(formatBytes(storageInfo.totalSpace))")
                    Text("Free Space: \(formatBytes(storageInfo.freeSpace))")
                    Text("Used Space: \(formatBytes(storageInfo.usedSpace))")
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding()
            } else {
                Text("Unable to retrieve storage information")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()

            Text("System Monitor")
                .font(.title)
                .padding()
            
            VStack {
                ProgressBar(value: cpuUsage, label: "CPU Usage", color: .blue)
                ProgressBar(value: memoryUsage, label: "Memory Usage", color: .green)
                ProgressBar(value: diskUsage, label: "Disk Usage", color: .orange)
            }
            .padding()
        }
        .onAppear {
            updateSystemInfo()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateSystemInfo()
            }
        }
        .padding()
    }

    private func updateSystemInfo() {
        cpuUsage = SystemMonitorHelper.getCPUUsage()
        memoryUsage = SystemMonitorHelper.getMemoryUsage()
        diskUsage = SystemMonitorHelper.getDiskUsage()
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct ProgressBar: View {
    var value: Double
    var label: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 10)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(self.value) * geometry.size.width / 100, geometry.size.width), height: 10)
                        .foregroundColor(self.color)
                        .animation(.bouncy)
                }
            }
            .frame(height: 10)
            .cornerRadius(5.0)
        }
        .padding(.bottom, 10)
    }
}
