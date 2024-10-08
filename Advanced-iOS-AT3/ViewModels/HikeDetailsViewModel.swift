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
    @Published var isFavourite: Bool
    
    init(hike: Hike) {
        self.hike = hike
        self.isFavourite = hike.isFavourite
        print(hike.rating)
    }
    
    func loadHikePhoto() {
        guard let photoMetaData = hike.photoReferences?[0] else {
            print("No photo meta data")
            return
        }
        
       // GMSPlacesClient.loadPlacePhoto(<#T##self: GMSPlacesClient##GMSPlacesClient#>)
        
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
                newFavouriteHike.address = hike.address
                newFavouriteHike.addTime = Date()
                
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
    
}
