//
//  BackupRow.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import SwiftUI

struct BackupRow: View {
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

