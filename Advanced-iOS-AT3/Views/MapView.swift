//
//  MapView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @FocusState private var isFocusedTextField: Bool
    @Environment(\.colorScheme) var colorScheme // Detect light or dark mode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showRecentSearches = false // State variable to control the popover
    @StateObject private var debouncer = Debouncer()
    

    
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
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .focused($isFocusedTextField)
                    .font(.title3)
                    .overlay {
                        ClearButton(text: $viewModel.searchableText)
                            .padding(.trailing, 20)
                            .padding(.bottom)
                    }
                
                if(!viewModel.recentSearches.isEmpty) {
                    HStack {
                        Button {
                            showRecentSearches.toggle()
                        } label: {
                            Text("Recent searches")
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        }
                        .popover(isPresented: $showRecentSearches) {
                            // Add recent searches view here if needed
                        }
                        
                        Spacer()
                    }
                }
                
                if(!viewModel.searchResults.isEmpty) {
                    List(viewModel.searchResults, id: \.self) { result in
                        Button {
                            viewModel.selectLocation(for: result, context: viewContext)
                            isFocusedTextField = false
                        } label: {
                            Text(result.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                    .listStyle(.plain)
                }
                else if(viewModel.searchResults.isEmpty && !viewModel.searchableText.isEmpty && viewModel.searchableText.count > 3 && viewModel.fetchingSuggestions == false) {
                    Text("No locations in Australia by that name.")
                    
                    Button {
                        viewModel.searchableText = ""
                    } label: {
                        Text("Clear search?")
                            .padding(6)
                    }
                }
                
                Spacer()
                
                if(!viewModel.isSearching) {
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            VStack {
                                
                                let size: CGFloat = {
                                    let delta = viewModel.region.span.latitudeDelta
                                    if delta > 1.0 {
                                        return 8 // Small size for zoomed-out view
                                    } else if delta > 0.1 {
                                        return 20 // Medium size for mid-zoom view
                                    } else {
                                        return 30 // Larger size for zoomed-in view
                                    }
                                }()
                                
                                if(viewModel.region.span.latitudeDelta > 0.5 || viewModel.region.span.longitudeDelta > 0.5) {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: size, height: size)
                                        .foregroundStyle(.orange)
                                }
                                else {
                                    Image(systemName: "figure.walk.diamond.fill")
                                        .resizable()
                                        .frame(width: size, height: size)
                                        .foregroundStyle(.orange)
                                    Text(annotation.title ?? "Unknown")
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    //.ignoresSafeArea()
                }
            }
        }
        .onChange(of: viewModel.region) { newValue in
            debouncer.debounce(delay: 0.5) { // Debounce with a 1-second delay
                print("Calling api \n")
                viewModel.fetchNearbyHikesByTextSearch()
                    
            }
        }
        .onAppear {
            locationManager.checkAuthorizationStatus()
            viewModel.region = locationManager.region
            viewModel.fetchNearbyHikesByTextSearch()
        }
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let context = persistenceController.container.viewContext
    
    MapView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
}
