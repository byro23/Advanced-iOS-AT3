//
//  SettingsView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

struct SettingsView: View {
    
    // Enum to represent the appearance mode
    enum AppearanceMode: String, CaseIterable, Identifiable {
       case light, dark, system
       var id: String { rawValue }
    }
    
    // Utilising UserDefaults for persistent storage
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                /*Text("Settings")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding() */
                
                Form {
                    Section(header: Text("Appearance")) {
                        Picker("Theme", selection: $appearanceMode) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
