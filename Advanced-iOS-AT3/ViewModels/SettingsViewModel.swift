//
//  SettingsViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//

import Foundation
import CoreData

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var tappedRestore: Bool = false
    @Published var tappedDelete: Bool = false
    
    @Published var isLoading = false
    @Published var isSuccessful = false
    @Published var noCloudBackup = false
    @Published var isFailure = false
    
    @Published var statusMessage = ""
    
    var statusMessages: [String] = [
        "Restore successful ✅",
        "Error restoring backup. Try again.",
        "Error deleting favourites backup. Try again.",
        "No favourites backup found. Please add a backup first.",
        "Backup successfully deleted. ",
        "No backup exists."
    ]
    
    fileprivate func removeStatusAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.statusMessage = ""
        }
    }
    
    func restoreBackup(context: NSManagedObjectContext) async {
        statusMessage = ""
        
        isLoading = true
        isSuccessful = false
        isFailure = false
        do {
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites()
            
            if favouritesSnapshot.isEmpty {
                isFailure = true
                isLoading = false
                statusMessage = statusMessages[3]
                removeStatusAfterDelay()
                return
            }
            
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
            isLoading = false
            isSuccessful = true
            statusMessage = statusMessages[0]
            
            removeStatusAfterDelay()
            
            print("Restore from backup successful.")
        }
        catch {
            // isFailure = true
            isLoading = false
            statusMessage = statusMessages[1]
            print("Error restoring backup: \(error.localizedDescription)")
            
            removeStatusAfterDelay()
        }
    }
    
    func deleteBackup() async {
        statusMessage = ""
        isSuccessful = false
        isLoading = true
        do {
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites()
            
            if(favouritesSnapshot.isEmpty) {
                isLoading = false
                statusMessage = statusMessages[5]
                removeStatusAfterDelay()
                return
            }
            
            try await FirebaseManager.shared.deleteCollection(FireStoreCollection.favourites.rawValue)
            isLoading = false
            isSuccessful = true
            statusMessage = statusMessages[4]
            
        } catch{
            statusMessage = statusMessages[2]
            print("Error deleting favourites backup.")
            
            removeStatusAfterDelay()
        }
        
        removeStatusAfterDelay()
        
    }
}
