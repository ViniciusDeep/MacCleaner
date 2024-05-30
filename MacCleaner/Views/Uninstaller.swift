//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

struct Uninstaller: View {
    @State private var applications: [Application] = []
    @State private var selectedApplication: Application?
    @State private var uninstallConfirmation = false
    @State private var uninstallResult = ""

    var body: some View {
        VStack {
            Text("Uninstaller")
                .font(.largeTitle)
                .padding()

            List(applications, id: \.self) { app in
                Button(action: {
                    selectedApplication = app
                    uninstallConfirmation.toggle()
                }) {
                    Text(app.name)
                }
            }
            .frame(width: 300, height: 300)

            Spacer()
        }
        .padding()
        .alert(isPresented: $uninstallConfirmation) {
            Alert(
                title: Text("Confirm Uninstall"),
                message: Text("Are you sure you want to uninstall \(selectedApplication?.name ?? "")?"),
                primaryButton: .destructive(Text("Uninstall")) {
                    uninstallApplication()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            fetchInstalledApplications()
        }
    }

    private func fetchInstalledApplications() {
        let applicationsURL = URL(fileURLWithPath: "/Applications")
        do {
            let applicationURLs = try FileManager.default.contentsOfDirectory(
                at: applicationsURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            for url in applicationURLs {
                if url.pathExtension == "app" {
                    let appName = url.lastPathComponent.replacingOccurrences(of: ".app", with: "")
                    if let bundle = Bundle(url: url) {
                        if let bundleID = bundle.bundleIdentifier {
                            applications.append(Application(name: appName, bundleID: bundleID))
                        }
                    }
                }
            }
        } catch {
            print("Error fetching installed applications: \(error.localizedDescription)")
        }
    }

    private func uninstallApplication() {
        guard let app = selectedApplication else { return }
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: "/Applications/\(app.name).app"))
            uninstallResult = "\(app.name) has been uninstalled successfully."
            // Remove the uninstalled application from the list
            applications.removeAll(where: { $0 == app })
        } catch {
            uninstallResult = "Failed to uninstall \(app.name)."
        }
    }
}

struct Application: Hashable {
    let name: String
    let bundleID: String
}

struct Uninstaller_Previews: PreviewProvider {
    static var previews: some View {
        Uninstaller()
    }
}
