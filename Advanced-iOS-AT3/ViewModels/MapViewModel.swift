import Foundation
import CoreData
import MapKit
import Combine
import GooglePlaces

class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var annotations: [Hike] = [] // Stores the annotation information
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )
    
    // Ultimo Area
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        
    @Published var searchableText: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var nearbyHikeResults: [GMSPlace] = []
    var fetchingSuggestions: Bool = false
    var isZoomedIn: Bool = true
    
    private var cancellable: AnyCancellable?
    private var searchCompleter = MKLocalSearchCompleter()
    
    private let context: NSManagedObjectContext
    
    var isSearching: Bool {
        return !searchableText.isEmpty
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init() // Initialize the superclass (NSObject)
        
        // Handle debounced input from the search field
        cancellable = $searchableText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                
                fetchingSuggestions = true
                
                // Update the queryFragment of the searchCompleter
                if query.isEmpty {
                    self.searchResults = [] // Clear results when query is empty
                } else {
                    fetchingSuggestions = true
                    // Set searchCompleter properties
                    searchCompleter.resultTypes = .address
                    searchCompleter.delegate = self
                    
                    let australiaRegion = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751),
                        span: MKCoordinateSpan(latitudeDelta: 35.0, longitudeDelta: 40.0)
                    )
                    
                    // Limit region to Australia
                    searchCompleter.region = australiaRegion
                    
                    
                    self.searchCompleter.queryFragment = query
                    
                    fetchingSuggestions = false
                }
            }
        
        
    }
    
    // Takes the user to the searched/suggested location
    func selectLocation(for suggestion: MKLocalSearchCompletion,  context: NSManagedObjectContext) {
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                
                self.searchableText = ""
            }
        }
    }
    
    @MainActor
    func fetchNearbyHikesByTextSearch() { // Fetches the places (importantly the coordinates) through the Google Places API
        
        var searchRadius: Double
        
        // Defines the search radiuses for hikes based on map zoom
        if region.span.longitudeDelta > 0.5 || region.span.latitudeDelta > 0.5 {
            searchRadius = 50000 // 50 km for zoomed-out view (country-level)
        } else if region.span.longitudeDelta > 0.1 || region.span.latitudeDelta > 0.1 {
            searchRadius = 10000 // 10 km for region-level view
        } else if region.span.longitudeDelta > 0.05 || region.span.latitudeDelta > 0.05 {
            searchRadius = 5000 // 5 km for city-level view
        } else if region.span.longitudeDelta > 0.01 || region.span.latitudeDelta > 0.01 {
            searchRadius = 1000 // 1 km for medium zoom
        } else {
            searchRadius = 500 // 500 meters for highly zoomed-in view
        }
        
        let circularLocationRestriction = GMSPlaceCircularLocationOption(region.center, searchRadius)
        
        // Specify the location must relate to 'hiking trail'
        let textQuery = "Hiking trail"
        
        // Specify the fields to return in the GMSPlace object for each place in the response.
        let placeProperties = [
            GMSPlaceProperty.placeID,
            GMSPlaceProperty.name,
            GMSPlaceProperty.coordinate,
            GMSPlaceProperty.editorialSummary,
            GMSPlaceProperty.formattedAddress,
            GMSPlaceProperty.rating,
            GMSPlaceProperty.userRatingsTotal,
            GMSPlaceProperty.iconImageURL,
        ].map {$0.rawValue}
        
        // Define the request based on the text query and desired properties
        let request = GMSPlaceSearchByTextRequest(textQuery: textQuery, placeProperties: placeProperties)
        
        // Specify the location region to search
        request.locationBias = circularLocationRestriction
        
        // Undergo the request
        let callback: GMSPlaceSearchByTextResultCallback = { [weak self] results, error in
          guard let self, error == nil else {
            if let error {
              print(error.localizedDescription)
            }
            return
          }
          guard let results = results as? [GMSPlace] else {
            return
          }
            nearbyHikeResults = results // Assign the results to the class-wide property
        }
        
        // Pass callback to search function
        GMSPlacesClient.shared().searchByText(with: request, callback: callback)
        
        // Begin annotating the map based on the results
        annotateNearbyHikes()
    }
    
    private func annotateNearbyHikes() {
        
        let visibleRegion = region
        
      // Helper function to check if a coordinate is within the visible region
       func isCoordinateVisible(coordinate: CLLocationCoordinate2D, region: MKCoordinateRegion) -> Bool {
           let minLat = region.center.latitude - region.span.latitudeDelta / 2
           let maxLat = region.center.latitude + region.span.latitudeDelta / 2
           let minLon = region.center.longitude - region.span.longitudeDelta / 2
           let maxLon = region.center.longitude + region.span.longitudeDelta / 2
           
           return coordinate.latitude >= minLat && coordinate.latitude <= maxLat &&
                  coordinate.longitude >= minLon && coordinate.longitude <= maxLon
       }
        
        // Remove annotations that are outside the visible region
        annotations = annotations.filter { annotation in
            if !isCoordinateVisible(coordinate: annotation.coordinate, region: visibleRegion) {
                // Annotation is outside the visible region
                return false // Remove from annotations array
            }
            return true // Keep annotation in the array
        } 
        
           // Iterate over the fetched nearby hike results and create annotations
           for hikePlace in nearbyHikeResults {
               // Extract name, coordinate, and summary
               let placeId = hikePlace.placeID
               let name = hikePlace.name
               let coordinate = hikePlace.coordinate
               let summary = hikePlace.editorialSummary // If available
               let address = hikePlace.formattedAddress
               let rating = hikePlace.rating
               let userRatingsTotal = hikePlace.userRatingsTotal
               let imageURL = hikePlace.iconImageURL
               
               let favouriteHikes = fetchFavoriteHikes() // Fetch the local stored favourites
               
               // Create the annotation
               let hike = Hike(placeId: placeId, summary: summary, address: address, rating: rating, userRatingsTotal: Int(userRatingsTotal), imageURL: imageURL, title: name, coordinate: coordinate)
               
               // If core data contains a hike location with the same id, mark it as favourite
               if favouriteHikes.contains(where: { $0.placeId == placeId }) {
                   hike.isFavourite = true
               }
               
               // Check if an annotation with the same title exists
               if let existingIndex = annotations.firstIndex(where: { $0.title == hike.title }) {
                   // If the existing annotation has a different favorite status, replace it
                   if annotations[existingIndex].isFavourite != hike.isFavourite {
                       annotations.remove(at: existingIndex) // Remove the existing annotation
                       annotations.append(hike) // Add the new hike annotation
                   }
               } else {
                   // If no existing annotation is found, append the new hike annotation
                   annotations.append(hike)
               }

           }
        
    }
    
    // Helper function that fetches favourite hikes from core data
    func fetchFavoriteHikes() -> [FavouriteHikes] {
        let fetchRequest: NSFetchRequest<FavouriteHikes> = FavouriteHikes.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching favorite hikes: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - MKLocalSearchCompleterDelegate methods
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update the searchResults array when the completer gets new results
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error occurred during search completion: \(error.localizedDescription)")
    }
    
}
