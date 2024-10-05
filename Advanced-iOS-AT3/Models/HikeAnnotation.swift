//
//  AnnotationItem.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import Foundation
import MapKit

import MapKit

class HikeAnnotation: NSObject, MKAnnotation, Identifiable {
    let id: UUID = UUID()
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let summary: String?
    
    init(title: String?, coordinate: CLLocationCoordinate2D, summary: String?) {
        self.title = title
        self.coordinate = coordinate
        self.summary = summary
    }
}

