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

class Hike: NSObject, MKAnnotation, Identifiable {
    let id: String = UUID().uuidString
    let placeId: String?
    let summary: String?
    let address: String?
    let rating: Float
    let imageURL: URL?
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let photoReferences: [GMSPlacePhotoMetadata]?
    var isFavourite: Bool = false
    
    init(placeId: String?, summary: String?, address: String?, rating: Float, imageURL: URL?, title: String?, coordinate: CLLocationCoordinate2D, photoReferences: [GMSPlacePhotoMetadata]?) {
        self.placeId = placeId
        self.summary = summary
        self.address = address
        self.rating = rating
        self.imageURL = imageURL
        self.title = title
        self.coordinate = coordinate
        self.photoReferences = photoReferences
    }
}

extension Hike {
    static let coordinates = CLLocationCoordinate2D(latitude: 55, longitude: 55)
    static let mock_hike = Hike(placeId: "123", summary: "The best walk across the beaches of Sydney", address: "Epic Beach Walk Road", rating: 4.5, imageURL: nil, title: "Bondi Beach Walk", coordinate: coordinates, photoReferences: nil)
}


