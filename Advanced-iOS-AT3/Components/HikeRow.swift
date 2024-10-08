//
//  HikeRow.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 8/10/2024.
//

import SwiftUI

struct HikeRow: View {
    var hike: FavouriteHikes
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(hike.placeName ?? "No place name available.")
                .font(.headline)
            Text(hike.address ?? "No address available.")
                .font(.subheadline)
        }
    }
}
