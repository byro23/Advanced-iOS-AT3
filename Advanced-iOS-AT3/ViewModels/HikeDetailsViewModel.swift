//
//  HikeDetailsViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 6/10/2024.
//

import Foundation
import UIKit
import GooglePlaces

class HikeDetailsViewModel: ObservableObject {
    
    @Published var hike: Hike
    @Published var hikeImage: UIImage?
    
    init(hike: Hike) {
        self.hike = hike
    }
    
    func loadHikePhoto() {
        guard let photoMetaData = hike.photoReferences?[0] else {
            print("No photo meta data")
            return
        }
        
       // GMSPlacesClient.loadPlacePhoto(<#T##self: GMSPlacesClient##GMSPlacesClient#>)
        
    }
}
