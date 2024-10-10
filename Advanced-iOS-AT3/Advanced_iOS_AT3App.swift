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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    let persistenceController = PersistenceController.shared
    @StateObject private var navigationController = NavigationController()
    @StateObject private var mapViewModel = MapViewModel(context: PersistenceController.shared.container.viewContext)
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationController.path) {
                UserView()
                    .navigationDestination(for: NavigationController.AppScreen.self) { screen in
                        switch screen {
                        case .HikeDetails(let hike):
                            HikeDetailsView(hike: hike)
                        }
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(navigationController)
            .environmentObject(mapViewModel)
            .preferredColorScheme(colorScheme(for: appearanceMode))
        }
    }
    
    func colorScheme(for appearanceMode: AppearanceMode) -> ColorScheme? {
        switch appearanceMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
