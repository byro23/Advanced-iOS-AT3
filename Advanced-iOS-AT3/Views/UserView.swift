//
//  HomeView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 4/10/2024.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var navigationController: NavigationController
    
    var body: some View {
        TabView(selection: $navigationController.currentTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.circle.fill")
                }
                .tag(NavigationController.Tab.map)
        }
    }
}

#Preview {
    UserView()
        .environmentObject(NavigationController())
}
