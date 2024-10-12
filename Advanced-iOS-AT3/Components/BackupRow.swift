//
//  BackupRow.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import SwiftUI

// MARK: - View
struct BackupRow: View { // The view component of the favourite backup rows
    // MARK: - Properties
    var favourite: FavouriteHike
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(favourite.placeName)
                .font(.headline)
            Text(favourite.address)
                .font(.subheadline)
        }
    }
}

