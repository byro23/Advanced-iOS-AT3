//
//  AnnotationItem.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import Foundation
import MapKit
import GooglePlaces

import MapKit

// The model for each hike - primarily used in the map annotations
class Hike: NSObject, MKAnnotation, Identifiable {
    let id: String = UUID().uuidString
    let placeId: String?
    let summary: String?
    let address: String?
    let rating: Float
    let userRatingsTotal: Int
    let imageURL: URL?
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var isFavourite: Bool = false
    
    init(placeId: String?, summary: String?, address: String?, rating: Float, userRatingsTotal: Int, imageURL: URL?, title: String?, coordinate: CLLocationCoordinate2D) {
        self.placeId = placeId
        self.summary = summary
        self.address = address
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.imageURL = imageURL
        self.title = title
        self.coordinate = coordinate
    }
}

extension Hike {
    static let coordinates = CLLocationCoordinate2D(latitude: 55, longitude: 55)
    static let mock_hike = Hike(placeId: "123", summary: "The best walk across the beaches of Sydney", address: "Epic Beach Walk Road", rating: 4.5, userRatingsTotal: 155, imageURL: nil, title: "Bondi Beach Walk", coordinate: coordinates)
}


