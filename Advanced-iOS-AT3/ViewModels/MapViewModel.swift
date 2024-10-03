import Foundation
import MapKit
import Combine

class MapViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published private(set) var annotationItems: [AnnotationItem] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: defaultRegion, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )
    
    private static let defaultRegion = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    
    @Published var searchableText: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private var cancellable: AnyCancellable?
    private var searchCompleter = MKLocalSearchCompleter()
    
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
    
    // MARK: - MKLocalSearchCompleterDelegate methods
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update the searchResults array when the completer gets new results
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error occurred during search completion: \(error.localizedDescription)")
    }
}
