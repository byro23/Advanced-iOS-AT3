//
//  HikeRow.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 8/10/2024.
//

import SwiftUI

// MARK: - View
struct HikeRow: View { // Provides the presentation of the rows in favourite hikes list
    
    // MARK: - Properties
    var hike: FavouriteHikes
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            Text(hike.placeName ?? "No place name available.")
                .font(.headline)
            Text(hike.address ?? "No address available.")
                .font(.subheadline)
        }
    }
}
