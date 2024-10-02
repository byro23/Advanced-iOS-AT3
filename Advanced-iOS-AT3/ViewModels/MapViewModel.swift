//
//  MapViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import Foundation
import MapKit


class MapViewModel: ObservableObject {
    
    @Published var queryFragment: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private var searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()
    
    private var PLACES_API_KEY = "AIzaSyDI99P3GEoDHLv8mXYFMeAoMIH8yLi6w4I"
    
}
