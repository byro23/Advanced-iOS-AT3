//
//  BackupViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import Foundation

@MainActor
class BackupViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false // Flag for fetching data
    @Published var favouriteHikes: [FavouriteHike] = [] // Stores the array of snapshot favourites
    
    // MARK: - Functions
    func fetchFavourites(uid: String) async {
        do {
            isLoading = true
            let favouritesSnapshot = try await FirebaseManager.shared.fetchFavourites(uid: uid)
            
            
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
