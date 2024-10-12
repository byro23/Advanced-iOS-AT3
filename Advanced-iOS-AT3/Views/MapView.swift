//  MapView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import SwiftUI
import MapKit

// View for displaying and interacting with a map, allowing users to search for hikes and view hike locations.
struct MapView: View {
    
    @EnvironmentObject private var viewModel: MapViewModel // View model for managing map data and search logic.
    @StateObject private var locationManager = LocationManager() // Manage location authorization and updates.
    @FocusState private var isFocusedTextField: Bool // Track focus state of the search text field.
    @Environment(\.colorScheme) var colorScheme // Detect light or dark mode.
    @Environment(\.managedObjectContext) private var viewContext // Core Data context for data operations.
    @EnvironmentObject var navigationController: NavigationController // Handle navigation between views.
    @StateObject private var debouncer = Debouncer() // Handle debouncing for API requests
    
    var body: some View {
        
        ZStack {
            
            VStack() {
                HeaderView() // Display header.
                    .padding(.top)
                
                // Search field for addresses or regions related to hikes.
                TextField("Search an address or region for hikes", text: $viewModel.searchableText)
                    .padding() // Add padding inside the TextField.
                    .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.2)) // Light gray background.
                    .cornerRadius(10) // Rounded corners for better appearance.
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // Text color based on color scheme.
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2) // Add border to the search field.
                    )
                    .padding(.horizontal)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled() // Disable autocorrection for search input.
                    .focused($isFocusedTextField) // Bind focus state.
                    .font(.title3) // Set font size for the text field.
                    .overlay {
                        ClearButton(text: $viewModel.searchableText) // Button to clear the search text.
                            .padding(.trailing, 20)
                    }
                
                // Display search results in a list if available.
                if(!viewModel.searchResults.isEmpty) {
                    List(viewModel.searchResults, id: \.self) { result in
                        Button {
                            viewModel.selectLocation(for: result, context: viewContext) // Handle selection of a search result.
                            isFocusedTextField = false // Dismiss keyboard when selecting a location.
                        } label: {
                            Text(result.title) // Display search result title.
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                    .listStyle(.plain) // Use plain list style for results.
                }
                // Display message if no results are found.
                else if(viewModel.searchResults.isEmpty && !viewModel.searchableText.isEmpty && viewModel.searchableText.count > 3 && viewModel.fetchingSuggestions == false) {
                    Text("No locations in Australia by that name.") // Message for no results found.
                    
                    Button {
                        viewModel.searchableText = "" // Clear the search text.
                    } label: {
                        Text("Clear search?")
                            .padding(6)
                    }
                }
                
                Spacer()
                
                // Display the map with hike annotations if not currently searching.
                if(!viewModel.isSearching) {
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            VStack {
                                // Determine annotation size based on map zoom level.
                                let size: CGFloat = {
                                    let delta = viewModel.region.span.latitudeDelta
                                    if delta > 1.0 {
                                        return 8 // Small size for zoomed-out view.
                                    } else if delta > 0.1 {
                                        return 20 // Medium size for mid-zoom view.
                                    } else {
                                        return 30 // Larger size for zoomed-in view.
                                    }
                                }()
                                
                                // Display hike annotations with different icons based on zoom level and favourite status.
                                if(viewModel.region.span.latitudeDelta > 0.5 || viewModel.region.span.longitudeDelta > 0.5) {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: size, height: size)
                                        .foregroundStyle(annotation.isFavourite ? .red : .orange) // Use red for favourites.
                                } else {
                                    Image(systemName: annotation.isFavourite ? "heart.fill" : "figure.walk.diamond.fill")
                                        .resizable()
                                        .frame(width: size, height: size)
                                        .foregroundStyle(annotation.isFavourite ? .red : .orange)
                                        .onTapGesture {
                                            navigationController.path.append(NavigationController.AppScreen.HikeDetails(hike: annotation)) // Navigate to hike details.
                                        }
                                    Text(annotation.title ?? "Unknown") // Display hike title.
                                        .font(.caption)
                                        .padding(5)
                                        .background(colorScheme == .dark ? Color.gray.opacity(0.8) : Color.white.opacity(0.8)) // Background color for text.
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.region) {
            debouncer.debounce(delay: 1) { // Debounce API calls with a 1-second delay.
                print("Calling API \n")
                viewModel.fetchNearbyHikesByTextSearch() // Fetch nearby hikes when the region changes.
            }
        }
        .onAppear {
            locationManager.checkAuthorizationStatus() // Check location authorization on view load.
            viewModel.fetchNearbyHikesByTextSearch() // Fetch initial nearby hikes.
        }
    }
}

// Extension to compare MKCoordinateRegion objects.
extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
    }
}

// Preview for testing MapView.
#Preview {
    let persistenceController = PersistenceController.preview
    let context = persistenceController.container.viewContext
    
    MapView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext) // Provide Core Data context.
}
