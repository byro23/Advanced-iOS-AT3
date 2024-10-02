//
//  MapView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import SwiftUI
import MapKit
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update your map view if needed
    }
}

struct MapView: View {
    
    // -33.884218746005494, 151.19973840164022
    
    @StateObject var viewModel = MapViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.884218746005494, longitude: 151.19973840164022),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        VStack {
            HeaderView()
                .padding()
            
            HStack {
                TextField("Search for a location", text: $viewModel.queryFragment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                
            }
            
            Map(position: $cameraPosition)
        }
        .searchable(text: $viewModel.queryFragment)
    }
}

#Preview {
    MapView()
}
