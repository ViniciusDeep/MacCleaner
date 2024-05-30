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
            NavigationLink(destination: SystemMonitor()) {
                Label("System Monitor", systemImage: "waveform.path.ecg")
            }
        }
        .listStyle(SidebarListStyle())
    }
}
