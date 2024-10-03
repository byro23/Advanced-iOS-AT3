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
    
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.87978316775921, longitude: 151.19853677853445), // Default to Sydney
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    
    var body: some View {
        
        VStack() {
            HeaderView()
                .padding(.top)
            
            TextField("Search an address or region for hikes", text: $viewModel.searchableText)
                .padding(.horizontal)
                .padding(.bottom)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .focused($isFocusedTextField)
                .font(.title2)
                .overlay {
                    ClearButton(text: $viewModel.searchableText)
                        .padding(.trailing, 18)
                        .padding(.bottom)
                }
            
            if(!viewModel.searchResults.isEmpty) {
                List(viewModel.searchResults, id: \.self) { result in
                    Button {
                        
                    } label: {
                        Text(result.title)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: 200)
            }
            
            Map(coordinateRegion: $region)
            .ignoresSafeArea()
        }
        .onAppear {
            locationManager.checkAuthorizationStatus()
            region = locationManager.region
            isFocusedTextField = true
        }
    }
}

#Preview {
    MapView()
}
