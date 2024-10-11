//  HomeView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 4/10/2024.
//

import SwiftUI

// Main user interface view containing a TabView for navigating between Map, Favourites, and Settings.
struct UserView: View {
    @EnvironmentObject var navigationController: NavigationController // Access the navigation controller for handling tab selection.
    
    var body: some View {
        // A TabView for navigating between different app sections.
        TabView(selection: $navigationController.currentTab) {
            MapView() // Display the map view.
                .tabItem {
                    Label("Map", systemImage: "map.circle.fill") // Tab label for map section.
                }
                .tag(NavigationController.Tab.map) // Tag for identifying the map tab.
            
            FavouritesView() // Display the favourites view.
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill") // Tab label for favourites section.
                }
                .tag(NavigationController.Tab.favourites) // Tag for identifying the favourites tab.
            
            SettingsView() // Display the settings view.
                .tabItem {
                    Label("Settings", systemImage: "gear") // Tab label for settings section.
                }
                .tag(NavigationController.Tab.settings) // Tag for identifying the settings tab.
        }
    }
}

// Preview for testing the UserView with a mock environment object.
#Preview {
    UserView()
        .environmentObject(NavigationController()) // Provide a mock NavigationController for the preview.
}
