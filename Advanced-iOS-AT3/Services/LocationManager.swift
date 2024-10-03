//
//  LocationManager.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import Foundation
import CoreLocation
import MapKit

// Sydney Coordinates 33.8688° S, 151.2093° E

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 33.8688, longitude: 151.2093), // Default to Sydney
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    
      var manager = CLLocationManager()
      
      
      func checkLocationAuthorization() {
          
          manager.delegate = self
          manager.startUpdatingLocation()
          
          switch manager.authorizationStatus {
          case .notDetermined://The user choose allow or deny your app to get the location yet
              manager.requestWhenInUseAuthorization()
              
          case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
              print("Location restricted")
              
          case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
              print("Location denied")
              
          case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
              print("Location authorizedAlways")
              
          case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
              print("Location authorized when in use")
              lastKnownLocation = manager.location?.coordinate
              
          @unknown default:
              print("Location service disabled")
          
          }
      }
      
      func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { // every time authorization status changes
          checkLocationAuthorization()
      }
      
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          lastKnownLocation = locations.first?.coordinate
      }
}
