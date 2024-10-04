//
//  Advanced_iOS_AT3App.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 18/9/2024.
//

import SwiftUI
import FirebaseCore
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // For CoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyDataModel") // Name should match your data model file
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // For CoreData
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
    return true
        
    }
}

@main
struct Advanced_iOS_AT3App: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // Observing the appearance mode stored in UserDefaults
    @AppStorage("appearanceMode") private var appearanceMode: SettingsView.AppearanceMode = .system
    
    var body: some Scene {
        WindowGroup {
            MapView()
                .preferredColorScheme(colorScheme(from: appearanceMode))
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
