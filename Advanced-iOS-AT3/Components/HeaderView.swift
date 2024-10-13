//
//  HeaderView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import SwiftUI

// MARK: - View 
struct HeaderView: View { // Provides the hikes near me logo and name
    var body: some View {
        HStack {
            
            Image(systemName: "map")
                .imageScale(.large)
                .foregroundStyle(.green)
            
            Text("Hikes Near Me")
                .font(.title)
                .fontWeight(.semibold)
                
        }
    }
}

// MARK: - Preview
#Preview {
    HeaderView()
}
