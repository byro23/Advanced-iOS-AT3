//
//  Advanced_iOS_AT3App.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 18/9/2024.
//

import SwiftUI
import FirebaseCore
import GooglePlaces
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyDI99P3GEoDHLv8mXYFMeAoMIH8yLi6w4I")
        GMSServices.provideAPIKey("AIzaSyDI99P3GEoDHLv8mXYFMeAoMIH8yLi6w4I")

    return true
    }
}

@main
struct Advanced_iOS_AT3App: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
