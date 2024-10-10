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

class HikeDetailsViewModel: ObservableObject {
    
    @Published var hike: Hike
    @Published var hikeImage: UIImage?
    @Published var isFavourite: Bool = false
    @Published var loadingImage: Bool = false
    let placesClient = GMSPlacesClient.shared()
    
    
    init(hike: Hike) {
        self.hike = hike
        loadHikePhoto()
    }
    
    func loadHikePhoto() {
        loadingImage = true
        let placeId = hike.placeId
        
        placesClient.lookUpPhotos(forPlaceID: placeId ?? "") { (photos, error) in

          guard let photoMetadata: GMSPlacePhotoMetadata = photos?.results[0] else {
            return }

          // Request individual photos in the response list
          let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: CGSizeMake(4800, 4800))
            self.placesClient.fetchPhoto(with: fetchPhotoRequest, callback: {
            (photoImage: UIImage?, error: Error?) in
              guard let photoImage, error == nil else {
                  print("Handle photo error: \(String(describing: error?.localizedDescription))")
                  self.loadingImage = false
                return }
                self.hikeImage = photoImage
              print("Display photo Image: ")
            }
          )
        }
    }
    
    func addToFavourites(context: NSManagedObjectContext) {
        // Check if the hike is already a favorite
       
        let fetchRequest: NSFetchRequest<FavouriteHikes> = FavouriteHikes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeId == %@", hike.placeId ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            
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
