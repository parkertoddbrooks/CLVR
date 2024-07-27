//
//  ContentView.swift
//  DuplicateTimestampMenuBar
//
//  Created by Parker Todd Brooks on 7/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Duplicate + Timestamp", isOn: $isEnabled)
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 200)
    }
}

#Preview {
    ContentView()
}
