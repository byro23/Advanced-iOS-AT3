//
//  Advanced_iOS_AT3App.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 18/9/2024.
//

import SwiftUI
import FirebaseCore
import CoreData
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // For Firebase
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        GMSPlacesClient.provideAPIKey("AIzaSyDI99P3GEoDHLv8mXYFMeAoMIH8yLi6w4I")
        
        
        
    return true
        
    }
}

@main
struct Advanced_iOS_AT3App: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Observing the appearance mode stored in UserDefaults
    @AppStorage("appearanceMode") private var appearanceMode: SettingsView.AppearanceMode = .system
    
    let persistenceController = PersistenceController.shared
    
    @StateObject private var navigationController = NavigationController()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationController.path) {
                UserView()
                    .preferredColorScheme(colorScheme(from: appearanceMode))
                    .navigationDestination(for: NavigationController.AppScreen.self) { screen in
                     
                        switch screen {
                        case .HikeDetails(let hike):
                            HikeDetailsView(hike: hike)
                        }
                        
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext) // Inject Core Data context
            .environmentObject(navigationController)
            
        }
    }
    
    // Convert the stored AppearanceMode to SwiftUI ColorScheme
    private func colorScheme(from mode: SettingsView.AppearanceMode) -> ColorScheme? {
        switch mode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // Follow system setting
        }
    }
}
