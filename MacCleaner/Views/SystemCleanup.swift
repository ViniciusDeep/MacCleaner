//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

struct SystemCleanup: View {
    @State private var showSheet = false
    @State private var cleanupResult = ""
    @State private var showingResult = false

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
            .sheet(isPresented: $showSheet) {
                VStack {
                    Text("Confirm Cleanup")
                        .font(.headline)
                        .padding()

                    Text("Are you sure you want to clean your Mac? This will delete temporary files.")
                        .padding()

                    HStack {
                        Button(action: {
                            if performSystemCleanup() {
                                cleanupResult = "Cleanup Successful!"
                            } else {
                                cleanupResult = "Cleanup Failed!"
                            }
                            showingResult = true
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

            Spacer()
        }
        .padding()
    }
}
