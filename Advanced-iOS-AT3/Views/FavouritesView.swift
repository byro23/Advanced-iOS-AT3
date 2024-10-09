//
//  FavouritesView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 8/10/2024.
//

import SwiftUI
import MapKit

struct FavouritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigationController: NavigationController
    @EnvironmentObject var mapViewModel: MapViewModel
    @StateObject var viewModel = FavouritesViewModel()
    @State var tappedFavourite: Bool = false
    @State var selectedHike: FavouriteHikes?
    
    // Use @FetchRequest to fetch FavouriteHikes from Core Data
   @FetchRequest(
       entity: FavouriteHikes.entity(), // Entity to fetch
       sortDescriptors: [NSSortDescriptor(keyPath: \FavouriteHikes.addTime, ascending: true)], // Sort by add time
       animation: .default
   ) private var favouriteHikes: FetchedResults<FavouriteHikes>
    
    
    var body: some View {
        NavigationView {
            VStack {
                if(favouriteHikes.isEmpty) {
                    Text("No favourites.")
                        .font(.headline)
                        .padding()
                }
                else {
                    List {
                        ForEach(favouriteHikes) { hike in
                            HikeRow(hike: hike)
                                .onTapGesture {
                                    selectedHike = hike
                                    tappedFavourite = true
                                }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
            }
            .navigationTitle("Favourites")
            .confirmationDialog("Choose an option", isPresented: $tappedFavourite) {
                Button("Show on map") {
                    if let hike = selectedHike {
                        mapViewModel.region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: hike.latitude, longitude: hike.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        navigationController.currentTab = .map
                    }
                }
                
                Button("Show hike details") {
                    
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }
        
    }
    
    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { favouriteHikes[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Failed to delete: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
