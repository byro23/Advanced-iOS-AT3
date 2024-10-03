//
//  MapView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @FocusState private var isFocusedTextField: Bool
    
    var body: some View {
        
        VStack() {
            HeaderView()
                .padding()
            
            TextField("Search an address or region for hikes", text: $viewModel.searchableText)
                .padding()
                .autocorrectionDisabled()
                .focused($isFocusedTextField)
                .font(.title2)
            
            Map(coordinateRegion: $viewModel.region)
            .ignoresSafeArea()
        }
        .onAppear {
            locationManager.checkLocationAuthorization()
            isFocusedTextField = true
        }
    }
}

#Preview {
    MapView()
}
