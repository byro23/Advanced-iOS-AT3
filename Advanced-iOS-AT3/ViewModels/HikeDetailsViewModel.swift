//
//  HikeDetailsViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 6/10/2024.
//

import Foundation
import UIKit
import GooglePlaces
import CoreData

@MainActor
class HikeDetailsViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var hike: Hike
    @Published var hikeImage: UIImage?
    @Published var isFavourite: Bool = false
    @Published var loadingImage: Bool = false
    
    
    init(hike: Hike) {
        self.hike = hike
    }
    
    // MARK: - Functions

    // Adds favourite by saving to core data
    func addToFavourites(context: NSManagedObjectContext) {
        // Check if the hike is already a favorite
        
        // Check if place is already a favourites (should never occur)
        let fetchRequest: NSFetchRequest<FavouriteHikes> = FavouriteHikes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeId == %@", hike.placeId ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            // If place does not already exist as favourite, add to core data
            if results.isEmpty {
                let newFavouriteHike = FavouriteHikes(context: context)
                newFavouriteHike.placeId = hike.placeId
                newFavouriteHike.placeName = hike.title
                newFavouriteHike.address = hike.address
                newFavouriteHike.addTime = Date()
                newFavouriteHike.latitude = hike.coordinate.latitude
                newFavouriteHike.longitude = hike.coordinate.longitude
                
                // Update favourite flag
                isFavourite = true
                
                try context.save()
                print("Hike added to favourites")
            }
            else {
                print("Hike already in favourites")
            }
        
        } catch {
            print("Error adding hike to favourites: \(error.localizedDescription)")
        }
        
    }
    
    // Removes favourite from core data
    func removeFromFavourite(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FavouriteHikes> = FavouriteHikes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeId == %@", hike.placeId ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let favouriteHike = results.first {
                // If the hike exists in favourites, remove it
                context.delete(favouriteHike)
                
                // Update the local isFavourite flag
                isFavourite = false
                
                // Save the context to persist the deletion
                try context.save()
                print("Hike removed from favourites")
            } else {
                print("Hike not found in favourites")
            }
            
        } catch {
            print("Error removing hike from favourites: \(error.localizedDescription)")
        }
    }

    
    func checkIfFavourite(context: NSManagedObjectContext) {
            let fetchRequest: NSFetchRequest<FavouriteHikes> = FavouriteHikes.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "placeId == %@", hike.placeId ?? "")
            
            do {
                let results = try context.fetch(fetchRequest)
                if(results.isEmpty) {
                    isFavourite = false
                }
                else {
                    isFavourite = true
                }
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    
}
