//
//  FavouriteHike.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import Foundation

// Defines the lightweight model for showing the backup snapshot
struct FavouriteHike: Identifiable {
    let id = UUID().uuidString
    let placeName: String
    let address: String
    
}
