//
//  SettingsViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//

import Foundation
import CoreData

@MainActor // MARK: - SettingsViewModel
class SettingsViewModel: ObservableObject {
    @Published var tappedRestore: Bool = false
    @Published var tappedDelete: Bool = false
    @Published var showSheet: Bool = false
    @Published var noBackup: Bool = false
    @Published var networkError: Bool = false
    
    @Published var isLoading = false
    @Published var isSuccessful = false
    @Published var statusMessage = ""
    
    // The various potential status messages
    var statusMessages: [String] = [
        "Restore successful ✅",
        "Error restoring backup. Try again.",
        "Error deleting favourites backup. Try again.",
        "No favourites backup found. Please add a backup first.",
        "Backup successfully deleted. ",
        "No backup exists."
    ]
    
    // Checks for an existing cloud backup
    func checkForBackup(uid: String) async -> Bool {
        do {
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites(uid: uid)
            
            if favouritesSnapshot.isEmpty {
                noBackup = true
                return false
            }
            
            return true
        } catch{
            networkError = true
            print("Error checking for backup: \(error.localizedDescription)")
            return false
        }
    }
    
    // Removes the status message after three seconds
    private func removeStatusAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.statusMessage = ""
        }
    }
    
    // Retrieves cloud backup and loads into favourites
    func restoreBackup(context: NSManagedObjectContext, uid: String) async {
        statusMessage = ""
        
        isLoading = true
        isSuccessful = false
        do {
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites(uid: uid)
            
            if favouritesSnapshot.isEmpty {
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
    
    // Deletes backup from remote database
    func deleteBackup(uid: String) async {
        statusMessage = ""
        isSuccessful = false
        isLoading = true
        do {
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites(uid: uid)
            
            if(favouritesSnapshot.isEmpty) {
                isLoading = false
                statusMessage = statusMessages[5]
                removeStatusAfterDelay()
                return
            }
            
            await FirebaseManager.shared.deleteFavourites(uid: uid)
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
