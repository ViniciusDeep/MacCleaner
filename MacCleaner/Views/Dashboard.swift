//
//  Dashboard.swift
//  MacCleaner
//
//  Created by Vinicius Mangueira on 29/05/24.
//

import SwiftUI

struct Dashboard: View {
    @State private var storageInfo: StorageInfo? = getStorageInfo()

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
        }
        .onAppear {
            self.storageInfo = getStorageInfo()
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
