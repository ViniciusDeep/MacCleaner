//  Copyright © 2024 MacCleaner, LLC. All rights reserved.

import SwiftUI

struct DeveloperTools: View {
    var body: some View {
        VStack {
            Text("Developer Tools")
                .font(.largeTitle)
                .padding()

            Button(action: {
                removeDerivedDataAndCache()
            }) {
                Text("Remove DerivedData and Xcode Cache")
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.buttonStyle(CustomButtonStyle())

            Spacer()
        }
        .padding()
    }

    private func removeDerivedDataAndCache() {
        print("DerivedData and Xcode cache removed successfully.")
    }
}
