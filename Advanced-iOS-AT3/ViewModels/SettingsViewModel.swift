//
//  SettingsViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//

import Foundation
import CoreData

class SettingsViewModel: ObservableObject {
    @Published var isRestoring = false
    @Published var isRestoreSuccessful = false
    @Published var isRestoreFailure = false
    
    func restoreBackup(context: NSManagedObjectContext) async {
        isRestoring = true
        isRestoreSuccessful = false
        isRestoreFailure = false
        do {
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites()
            
            // Clear existing Core Data "FavouriteHikes"
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavouriteHikes.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            // Perform the batch delete in Core Data
            try context.execute(deleteRequest)
            try context.save() // Save changes after deletion
            context.reset()
            
         for document in favouritesSnapshot {
                let data = document
                let favourite = FavouriteHikes(context: context)
                
                favourite.placeId = data["placeId"] as? String
                favourite.placeName = data["placeName"] as? String
                favourite.latitude = data["latitude"] as? Double ?? 0.0
                favourite.longitude = data["longitude"] as? Double ?? 0.0
                favourite.address = data["address"] as? String
                favourite.addTime = data["addTime"] as? Date
                
                try context.save()
            }
            isRestoring = false
            isRestoreSuccessful = true
            print("Restore from backup successful.")
        }
        catch {
            isRestoreFailure = true
            print("Error restoring backup: \(error.localizedDescription)")
        }
        
    }
}
