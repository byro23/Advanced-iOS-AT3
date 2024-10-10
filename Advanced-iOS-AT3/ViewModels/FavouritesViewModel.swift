//
//  FavouritesViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 8/10/2024.
//

import GooglePlaces
import Foundation
import CoreLocation
import CoreData
import FirebaseFirestore

class FavouritesViewModel: ObservableObject {
    
    private let placesClient = GMSPlacesClient.shared() // Initialize the GMSPlacesClient
    @Published var isLoading = false
    @Published var tappedFavourite = false
    @Published var tappedClearAll = false
    @Published var tappedCloudBackup = false
    @Published var isBackingUp = false
    @Published var backupSuccessful: Bool = false
    @Published var backupFailed: Bool = false
    
    // Function to fetch place details and return a Hike object
    @MainActor
    func fetchPlace(placeId: String) async -> Hike? {
        isLoading = true
        // Use Swift's async/await to handle the asynchronous callback
        return await withCheckedContinuation { continuation in
            // Specify the place data fields you want to fetch
            let fields: GMSPlaceField = [.name, .placeID, .coordinate, .formattedAddress, .rating, .userRatingsTotal, .iconImageURL]
            
            // Fetch place details from the Google Places API
            placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil) { (place: GMSPlace?, error: Error?) in
                if let error = error {
                    // Handle the error and return nil
                    print("An error occurred: \(error.localizedDescription)")
                    self.isLoading = false
                    continuation.resume(returning: nil)
                    return
                }
                
                if let place = place {
                    // Create a Hike object using the retrieved place details
                    let hike = Hike(
                        placeId: place.placeID,
                        summary: place.editorialSummary ?? "No summary available", // Use default if nil
                        address: place.formattedAddress,
                        rating: place.rating,
                        userRatingsTotal: Int(place.userRatingsTotal),
                        imageURL: place.iconImageURL,
                        title: place.name,
                        coordinate: place.coordinate
                    )
                    
                    // Print the place name for debugging
                    print("The selected place is: \(place.name ?? "Unknown")")
                    
                    self.isLoading = false
                    // Return the Hike object
                    continuation.resume(returning: hike)
                } else {
                    // If the place is nil, return nil
                    self.isLoading = false
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func deleteAllFavourites(context: NSManagedObjectContext) {
        // Create a fetch request to get all FavouriteHikes
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavouriteHikes.fetchRequest()
        
        // Create a batch delete request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            // Perform the batch delete request
            try context.execute(deleteRequest)
            
            // Used to refresh the view
            context.reset()
           
            // Save the context to persist the changes
            try context.save()
            
            print("All favourites deleted successfully")
        } catch let error as NSError {
            print("Could not delete favourites. \(error), \(error.userInfo)")
        }
    }
    
    @MainActor
    func backupFavourites(context: NSManagedObjectContext) async {
        isBackingUp = true
        
        let fetchRequest: NSFetchRequest<FavouriteHikes> = FavouriteHikes.fetchRequest()
        
        do {
            try await FirebaseManager.shared.deleteCollection(FireStoreCollection.favourites.rawValue) // Delete old backup
            
            let favouriteHikes = try context.fetch(fetchRequest)
            
            guard !favouriteHikes.isEmpty else {
                print("No favourites to backup")
                isBackingUp = false
                return
            }
            
            for hike in favouriteHikes {
                let hikeData: [String: Any] = [
                    "placeId": hike.placeId ?? "",
                    "placeName": hike.placeName ?? "",
                    "address" : hike.address ?? "",
                    "latitude" : Double(hike.latitude),
                    "longitude" : Double(hike.longitude),
                    "addTime" : hike.addTime as Any
                ]
                
                try await FirebaseManager.shared.addDocument(docData: hikeData, toCollection: FireStoreCollection.favourites.rawValue)
                print("Favourites added successfully.")
                backupSuccessful = true
                isBackingUp = false
            }
            
        } catch {
            isBackingUp = false
            print("Error adding document to database")
        }
    }
}

