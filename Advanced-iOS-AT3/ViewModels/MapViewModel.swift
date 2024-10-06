import Foundation
import CoreData
import MapKit
import Combine
import GooglePlaces

class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var annotations: [HikeAnnotation] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )
    
    // Ultimo Area
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        
    @Published var searchableText: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var recentSearches: [SearchQuery] = []
    @Published var nearbyHikeResults: [GMSPlace] = []
    
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
                
                // Update the queryFragment of the searchCompleter
                if query.isEmpty {
                    self.searchResults = [] // Clear results when query is empty
                } else {
                    self.searchCompleter.queryFragment = query
                }
            }
        
        // Set searchCompleter properties
        searchCompleter.resultTypes = .address
        searchCompleter.delegate = self
        
        let australiaRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751),
            span: MKCoordinateSpan(latitudeDelta: 35.0, longitudeDelta: 40.0)
        )
        
        searchCompleter.region = australiaRegion
    }
    
    // Method to get place from selected address and update the map region
    func getPlace(from address: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: address)
        
        Task {
            do {
                let response = try await MKLocalSearch(request: request).start()
                await MainActor.run {
                    
                    self.region = response.boundingRegion
                }
            } catch {
                print("Error occurred during search: \(error.localizedDescription)")
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
    func fetchNearbyHikes() {
        let circularLocationRestriction = GMSPlaceCircularLocationOption(region.center, 5000)
        
        let textQuery = "Hiking Trails"
        
        // Specify the fields to return in the GMSPlace object for each place in the response.
        let placeProperties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.editorialSummary].map {$0.rawValue}
        
        // Create the GMSPlaceSearchNearbyRequest, specifying the search area and GMSPlace fields to return.
        var request = GMSPlaceSearchNearbyRequest(locationRestriction: circularLocationRestriction, placeProperties: placeProperties)
        let includedTypes = ["park", "national_park"]
        request.includedTypes = includedTypes
        
        let callback: GMSPlaceSearchNearbyResultCallback = { [weak self] results, error in
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

        GMSPlacesClient.shared().searchNearby(with: request, callback: callback)
        
        annotateNearbyHikes()

    }
    
    @MainActor
    func fetchNearbyHikesByTextSearch() {
        let circularLocationRestriction = GMSPlaceCircularLocationOption(region.center, 5000)
        
        print("Region center: \(region.center)")
        
        let textQuery = "Hiking Trails"
        
        // Specify the fields to return in the GMSPlace object for each place in the response.
        let placeProperties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.editorialSummary].map {$0.rawValue}
        
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
        // Clear existing annotations
           annotations.removeAll()

           // Iterate over the fetched nearby hike results and create annotations
           for hikePlace in nearbyHikeResults {
               // Extract name, coordinate, and summary
               let name = hikePlace.name
               let coordinate = hikePlace.coordinate
               let summary = hikePlace.editorialSummary // If available
               
               // Create the annotation
               let annotation = HikeAnnotation(title: name, coordinate: coordinate, summary: summary)
               
               // Add to annotations array
               annotations.append(annotation)
           }
        
        if annotations.count > 0 {
            print(annotations[0].title)
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
