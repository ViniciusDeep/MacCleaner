//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Sidebar()
            Dashboard()
        }
    }
}

struct Sidebar: View {
    var body: some View {
        List {
            NavigationLink(destination: Dashboard()) {
                Label("Dashboard", systemImage: "gauge")
            }
            NavigationLink(destination: SystemCleanup()) {
                Label("System Cleanup", systemImage: "trash")
            }
            NavigationLink(destination: LargeFilesFinder()) {
                Label("Large & Old Files", systemImage: "doc.text.magnifyingglass")
            }
            NavigationLink(destination: Uninstaller()) {
                Label("Uninstaller", systemImage: "trash.slash")
            }
            NavigationLink(destination: DeveloperTools()) {
                Label("Developer", systemImage: "hammer")
            }
        }
        .listStyle(SidebarListStyle())
    }
}

#Preview {
    ContentView()
}


