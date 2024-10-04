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
    @Environment(\.colorScheme) var colorScheme // Detect light or dark mode
    
    /*
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.87978316775921, longitude: 151.19853677853445), // Default to Sydney
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ) */
    
    
    var body: some View {
        
        ZStack {
            
            VStack() {
                HeaderView()
                    .padding(.top)
                
                TextField("Search an address or region for hikes", text: $viewModel.searchableText)
                    .padding() // Add padding inside the TextField
                    .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.2)) // Light gray background for dark mode
                    .cornerRadius(10) // Rounded corners to match the overlay
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // White text in dark mode
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2) // Bright border in dark mode
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .focused($isFocusedTextField)
                    .font(.title3)
                    .overlay {
                        ClearButton(text: $viewModel.searchableText)
                            .padding(.trailing, 20)
                            .padding(.bottom)
                    }
                
                if(!viewModel.searchResults.isEmpty) {
                    List(viewModel.searchResults, id: \.self) { result in
                        Button {
                            viewModel.selectLocation(for: result)
                            isFocusedTextField = false
                        } label: {
                            Text(result.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                    .listStyle(.plain)
                }
                else if(viewModel.searchResults.isEmpty && !viewModel.searchResults.isEmpty) {
                    Text("No locations in Australia by that name.")
                    
                    Button {
                        viewModel.searchableText = ""
                    } label: {
                        Text("Clear search?")
                    }
                }
                
                Spacer()
                
                if(!viewModel.isSearching) {
                    Map(coordinateRegion: $viewModel.region)
                        .ignoresSafeArea()
                }
                
                
            }
            .onAppear {
                locationManager.checkAuthorizationStatus()
                viewModel.region = locationManager.region
                isFocusedTextField = true
            }
        }
    }
}

#Preview {
    MapView()
}
