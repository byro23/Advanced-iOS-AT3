//
//  BackupViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import Foundation

@MainActor
class BackupViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var backUpDate: Date?
    @Published var favouriteHikes: [FavouriteHike] = []
    
    func fetchFavourites() async {
        do {
            isLoading = true
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites()
            
            // backUpDate =
            
            for document in favouritesSnapshot {
                let data = document
                
                let favouriteHike = FavouriteHike(placeName: data["placeName"] as! String, address: data["address"] as! String)
                
                favouriteHikes.append(favouriteHike)
            }
            print(favouriteHikes[0].address)
            isLoading = false
            
        } catch {
            print("Error favourites snapshot: \(error.localizedDescription)")
        }
        
    }
}
