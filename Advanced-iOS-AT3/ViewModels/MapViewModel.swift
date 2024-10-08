import Foundation
import CoreData
import MapKit
import Combine
import GooglePlaces

class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var annotations: [Hike] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    // Ultimo Area
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        
    @Published var searchableText: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var recentSearches: [SearchQuery] = []
    @Published var nearbyHikeResults: [GMSPlace] = []
    var fetchingSuggestions: Bool = false
    var isZoomedIn: Bool = true
    
    private var cancellable: AnyCancellable?
    private var searchCompleter = MKLocalSearchCompleter()
    
    var isSearching: Bool {
        return !searchableText.isEmpty
    }
    
    override init() {
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
                    
                    searchCompleter.region = australiaRegion
                    
                    self.searchCompleter.queryFragment = query
                    
                    fetchingSuggestions = false
                }
            }
        
        
    }
    
    func selectLocation(for suggestion: MKLocalSearchCompletion,  context: NSManagedObjectContext) {
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                // print("Searched coordinates: \(coordinate.latitude) \(coordinate.longitude)")
                
                self.searchableText = ""
                self.saveRecentSearch(queryText: suggestion.title, latitude: coordinate.latitude, longitude: coordinate.longitude, context: context)
            }
        }
    }
    
    private func saveRecentSearch(queryText: String, latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        let newSearchQuery = NSEntityDescription.insertNewObject(forEntityName: "SearchQuery", into: context)
            
        newSearchQuery.setValue(queryText, forKey: "queryText")
        newSearchQuery.setValue(Date(), forKey: "date")
        newSearchQuery.setValue(latitude, forKey: "latitude")
        newSearchQuery.setValue(longitude, forKey: "longitude")
        
        do {
            try context.save()
            print("SearchQuery saved successfully!")
        } catch {
            print("Failed to save SearchQuery: \(error.localizedDescription)")
        }
        
    }
    
    // Function to fetch SearchQuery objects from Core Data
    func fetchRecentSearches(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<SearchQuery> = SearchQuery.fetchRequest()  // Create fetch request
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SearchQuery.date, ascending: false)]  // Sort by date
        
        do {
            // Execute fetch request and assign the result to recentSearches
            recentSearches = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching recent searches: \(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func fetchNearbyHikesByTextSearch() { // Fetches the places (importantly the coordinates) through the Google Places API
        
        var searchRadius: Double

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
        
        var circularLocationRestriction = GMSPlaceCircularLocationOption(region.center, searchRadius)
        
        //let circularLocationRestriction = GMSPlaceCircularLocationOption(region.center, 10000)
        
        print("Region center: \(region.center)")
        
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
            GMSPlaceProperty.photos
        ].map {$0.rawValue}
        
        let request = GMSPlaceSearchByTextRequest(textQuery: textQuery, placeProperties: placeProperties)
        
        request.locationBias = circularLocationRestriction
        
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
            nearbyHikeResults = results
        }

        GMSPlacesClient.shared().searchByText(with: request, callback: callback)
        
        annotateNearbyHikes()
    }
    
    private func annotateNearbyHikes() {
        
        let annotationLimit = 250
        
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
               let photoReferences = hikePlace.photos
               

               
               // Create the annotation
               let hike = Hike(placeId: placeId, summary: summary, address: address, rating: rating, userRatingsTotal: Int(userRatingsTotal), imageURL: imageURL, title: name, coordinate: coordinate, photoReferences: photoReferences)
               
               
               if !annotations.contains(where: { annotation in
                   return annotation.title == hike.title
               }) {
                   annotations.append(hike)
               }
           }
        
        // Optionally limit the number of annotations
        if annotations.count > annotationLimit {
            let excessAnnotations = annotations.count - annotationLimit
            annotations.removeFirst(excessAnnotations) // Remove oldest annotations
        }
        
        if annotations.count > 0 {
            print("Current annotations \(annotations.count)")
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
