import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // Ultimo Coordinates: -33.87978316775921, 151.19853677853445
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.87978316775921, longitude: 151.19853677853445), // Default to Sydney
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var manager = CLLocationManager()
    
    // Lazy initialization for CLLocationManager
    /*private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }() */
    
    // Check location authorization status and start updating location
    func checkAuthorizationStatus() {
        manager.delegate = self
        manager.startUpdatingLocation() // Start location updates
        
        switch manager.authorizationStatus {
        
        case .notDetermined:
            manager.requestWhenInUseAuthorization() // Request authorization
        
        case .restricted, .denied:
            print("Location access is restricted or denied.")
            
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = manager.location?.coordinate {
                updateRegion(for: location)
            }
        
        @unknown default:
            print("Unknown authorization status.")
        }
    }
    
    // Called when authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    // Called when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            updateRegion(for: location)
        }
    }
    
    // Helper function to update the map region
    private func updateRegion(for location: CLLocationCoordinate2D) {
        lastKnownLocation = location
        region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
