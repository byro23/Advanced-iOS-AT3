//
//  SettingsView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode) // Explicitly set the tag
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .navigationTitle("Settings")
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
   case light, dark, system
   var id: String { rawValue }
}


#Preview {
    SettingsView()
}
