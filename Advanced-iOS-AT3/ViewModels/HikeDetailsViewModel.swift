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
    
    @Published var hike: Hike
    @Published var hikeImage: UIImage?
    @Published var isFavourite: Bool = false
    @Published var loadingImage: Bool = false
    
    
    init(hike: Hike) {
        self.hike = hike
    }
    
    func loadHikePhoto() {
        loadingImage = true
        let placeId = hike.placeId
        
        print(hike.title)
        
        let placesClient = GMSPlacesClient.shared()

        placesClient.lookUpPhotos(forPlaceID: placeId ?? "") { (photos, error) in
            if let error = error {
                print("Error looking up photos: \(error.localizedDescription)")
                self.loadingImage = false
                return
            }

            guard let photoMetadata = photos?.results.first else {
                print("No photo metadata found for place: \(placeId ?? "Unknown")")
                self.loadingImage = false
                return
            }

            print("Photo metadata: \(photoMetadata)")
            

            // Request individual photos in the response list
            let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: CGSizeMake(512, 512))
            placesClient.fetchPhoto(with: fetchPhotoRequest) { (photoImage, error) in
                if let error = error {
                    print("Error fetching photo: \(error.localizedDescription)")
                    
                    if let nsError = error as NSError? {
                        print("Detailed error info: \(nsError)")
                        print("Error code: \(nsError.code), domain: \(nsError.domain)")
                    }
                    
                    self.loadingImage = false
                    return
                }

                guard let photoImage = photoImage else {
                    print("No photo returned from fetchPhoto")
                    self.loadingImage = false
                    return
                }

                DispatchQueue.main.async {
                    self.hikeImage = photoImage
                    self.loadingImage = false
                }
                print("Successfully fetched and displayed photo.")
            }
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
