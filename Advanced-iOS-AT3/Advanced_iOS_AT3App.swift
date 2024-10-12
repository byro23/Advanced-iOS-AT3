//
//  Advanced_iOS_AT3App.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 18/9/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import CoreData
import GooglePlaces

// AppDelegate handles app initialization, such as Firebase and Google Places API configuration.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // Configure Firebase and Google Places API on app launch.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Initialize Firebase services.
        GMSPlacesClient.provideAPIKey("AIzaSyDI99P3GEoDHLv8mXYFMeAoMIH8yLi6w4I")
        
        return true
    }
}

@main
struct Advanced_iOS_AT3App: App {
    
    // Attach AppDelegate to handle app life cycle and Firebase setup.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Retrieve appearance mode setting from AppStorage.
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    // Shared persistence controller for Core Data.
    let persistenceController = PersistenceController.shared
    
    // State objects for navigation and map data management.
    @StateObject private var navigationController = NavigationController()
    @StateObject private var mapViewModel = MapViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var authController = AuthController()
    
    var body: some Scene {
        WindowGroup {
            // Define the main view with navigation stack.
            NavigationStack(path: $navigationController.path) {
                LandingView() // Display user view.
                    .navigationDestination(for: NavigationController.AppScreen.self) { screen in
                        switch screen {
                        case .User:
                            UserView()
                        case .HikeDetails(let hike): // Navigate to hike details.
                            HikeDetailsView(hike: hike)
                        case .Register:
                            RegistrationView()
                        }
                        
                    }
            }
            // Provide Core Data context and environment objects to views.
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(navigationController)
            .environmentObject(mapViewModel)
            .environmentObject(authController)
            .preferredColorScheme(colorScheme(for: appearanceMode)) // Apply appearance mode.
        }
    }
    
    // Determine color scheme based on user preference.
    func colorScheme(for appearanceMode: AppearanceMode) -> ColorScheme? {
        switch appearanceMode {
        case .system: // Follow system-wide setting.
            return nil
        case .light: // Force light mode.
            return .light
        case .dark: // Force dark mode.
            return .dark
        }
    }
}
