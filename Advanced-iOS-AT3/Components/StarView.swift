//
//  StarView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 8/10/2024.
//

import SwiftUI

struct StarView: View {
    let rating: Double  // Rating of the hike, e.g., 4.5

    var body: some View {
        HStack(spacing: 2) {
            // Full stars
            ForEach(0..<fullStars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }

            // Half star
            if halfStar {
                Image(systemName: "star.leadinghalf.fill")
                    .foregroundColor(.yellow)
            }

            // Empty stars
            ForEach(0..<emptyStars, id: \.self) { _ in
                Image(systemName: "star")
                    .foregroundColor(.gray)
            }
        }
    }

    // Computed properties to determine full, half, and empty stars
    var fullStars: Int {
        return Int(rating)
    }

    var halfStar: Bool {
        return rating - Double(fullStars) >= 0.5
    }

    var emptyStars: Int {
        return 5 - fullStars - (halfStar ? 1 : 0)
    }
}


#Preview {
    StarView(rating: 3.5)
}
