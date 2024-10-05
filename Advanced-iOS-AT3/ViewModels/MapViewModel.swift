import Foundation
import MapKit
import Combine

class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published private(set) var annotationItems: [AnnotationItem] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )
    
    // Ultimo Area
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    
    
    @Published var searchableText: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
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
                    self.annotationItems = response.mapItems.map {
                        AnnotationItem(
                            latitude: $0.placemark.coordinate.latitude,
                            longitude: $0.placemark.coordinate.longitude
                        )
                    }
                    self.region = response.boundingRegion
                }
            } catch {
                print("Error occurred during search: \(error.localizedDescription)")
            }
        }
    }
    
    func selectLocation(for suggestion: MKLocalSearchCompletion) {
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
    
    // MARK: - MKLocalSearchCompleterDelegate methods
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update the searchResults array when the completer gets new results
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error occurred during search completion: \(error.localizedDescription)")
    }
    
}
