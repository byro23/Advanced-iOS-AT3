//
//  AnnotationItem.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import Foundation
import MapKit

import MapKit

class Hike: NSObject, MKAnnotation, Identifiable {
    let id: String = UUID().uuidString
    let summary: String?
    let address: String?
    let rating: Float
    let imageURL: URL?
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var isFavourite: Bool = false
    
    init(summary: String?, address: String?, rating: Float, imageURL: URL?, title: String?, coordinate: CLLocationCoordinate2D) {
        self.summary = summary
        self.address = address
        self.rating = rating
        self.imageURL = imageURL
        self.title = title
        self.coordinate = coordinate
    }
}

extension Hike {
    static let coordinates = CLLocationCoordinate2D(latitude: 55, longitude: 55)
    static let mock_hike = Hike(summary: "The best walk across the beaches of Sydney", address: "Epic Beach Walk Road", rating: 4.5, imageURL: nil, title: "Bondi Beach Walk", coordinate: coordinates)
}


