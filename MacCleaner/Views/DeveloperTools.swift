import SwiftUI

struct DeveloperTools: View {
    @State private var cleanupResult = ""
    @State private var showingResult = false

    var body: some View {
        VStack {
            Text("Developer Tools")
                .font(.largeTitle)
                .padding()

            Button(action: {
                removeDeveloperToolsCache()
            }) {
                Text("Remove Developer Tools Cache")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(CustomButtonStyle())
            .alert(isPresented: $showingResult) {
                Alert(
                    title: Text("Cleanup Result"),
                    message: Text(cleanupResult),
                    dismissButton: .default(Text("OK"))
                )
            }

            Spacer()
        }
        .padding()
    }

    private func removeDeveloperToolsCache() {
        DispatchQueue.global(qos: .background).async {
            let homeDirectory = NSHomeDirectory()
            
            let xcodeCacheDirectories = [
                "\(homeDirectory)/Library/Developer/Xcode/DerivedData",
                "\(homeDirectory)/Library/Caches/com.apple.dt.Xcode",
                "\(homeDirectory)/Library/Developer/Xcode/Index/DataStore"
            ]
            
            let vscodeCacheDirectories = [
                "\(homeDirectory)/Library/Application Support/Code",
                "\(homeDirectory)/Library/Caches/com.microsoft.VSCode",
                "\(homeDirectory)/Library/Caches/com.microsoft.VSCode.ShipIt"
            ]

            let additionalToolCacheDirectories = [
                "\(homeDirectory)/Library/Caches/com.apple.dt.instruments",
                "\(homeDirectory)/Library/Developer/CoreSimulator/Caches"
            ]

            let allCacheDirectories = xcodeCacheDirectories + vscodeCacheDirectories + additionalToolCacheDirectories
            var result = true

            do {
                for dir in allCacheDirectories {
                    if FileManager.default.fileExists(atPath: dir) {
                        let files = try FileManager.default.contentsOfDirectory(atPath: dir)
                        for file in files {
                            let filePath = (dir as NSString).appendingPathComponent(file)
                            try FileManager.default.removeItem(atPath: filePath)
                        }
                    }
                }
            } catch {
                print("Error during cleanup: \(error.localizedDescription)")
                result = false
            }

            DispatchQueue.main.async {
                cleanupResult = result ? "Developer tools cache removed successfully." : "Failed to remove some cache files."
                showingResult = true
            }
        }
    }
}
