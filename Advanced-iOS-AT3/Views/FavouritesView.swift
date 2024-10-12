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
    @EnvironmentObject var authController: AuthController
    @StateObject var viewModel = FavouritesViewModel()
    @State var selectedHike: FavouriteHikes?
    // Use @FetchRequest to fetch FavouriteHikes from Core Data
   @FetchRequest(
       entity: FavouriteHikes.entity(), // Entity to fetch
       sortDescriptors: [NSSortDescriptor(keyPath: \FavouriteHikes.addTime, ascending: false)], // Sort by add time
       animation: .default
   ) private var favouriteHikes: FetchedResults<FavouriteHikes>
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    
                    Button {
                        viewModel.tappedCloudBackup = true
                    } label: {
                        if(!favouriteHikes.isEmpty && viewModel.isBackingUp == false) {
                            Image(systemName: "icloud.and.arrow.up")
                            Text("Cloud backup")
                        }
                        else if(viewModel.isBackingUp) {
                            HStack {
                                Text("Uploading")
                                ProgressView()
                            }
                        }
                    }
                    .padding()
                    
                    
                    Button {
                        viewModel.tappedClearAll = true
                    } label: {
                        if(!favouriteHikes.isEmpty) {
                            Text("Clear all")
                        }
                    }
                    .padding()
                
                }
                
                if(viewModel.backupSuccessful) {
                    Text("Backup successful")
                        .foregroundStyle(.green)
                }
                
                if(viewModel.backupFailed) {
                    Text("Error occurred during backup. Try again.")
                        .foregroundStyle(.red)
                }
                
                
                
                
                
                if(favouriteHikes.isEmpty) {
                    Text("No favourites.")
                        .font(.headline)
                        .padding()
                }
                else if(viewModel.isLoading) {
                    ProgressView()
                    Spacer()
                }
                else {
                    List {
                        ForEach(favouriteHikes) { hike in
                            HikeRow(hike: hike)
                                .onTapGesture {
                                    selectedHike = hike
                                    viewModel.tappedFavourite = true
                                }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
            }
            .navigationTitle("Favourites")
            .confirmationDialog("Choose an option", isPresented: $viewModel.tappedFavourite) {
                Button("Show on map") {
                    if let hike = selectedHike {
                        print("Saved hike latitude: \(hike.latitude). Saved hike longitude: \(hike.longitude)")
                        mapViewModel.region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: hike.latitude, longitude: hike.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        navigationController.currentTab = .map
                    }
                }
                
                Button("Show hike details") {
                    Task {
                        if let hike = await viewModel.fetchPlace(placeId: selectedHike?.placeId ?? "") {
                            // Now you can use the hike object outside of the callback
                            print("Hike found: \(hike.title ?? "No title")")
                            // For example, navigate to another screen with the hike details
                            navigationController.path.append(NavigationController.AppScreen.HikeDetails(hike: hike))
                        } else {
                            print("No hike found.")
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .alert("Are you sure? This action cannot be undone.", isPresented: $viewModel.tappedClearAll) {
                Button("Delete all", role: .destructive) {
                    viewModel.deleteAllFavourites(context: viewContext)
                    viewModel.tappedClearAll = false
                }
                Button("Cancel", role: .cancel) {
                    viewModel.tappedClearAll = false
                }
            }
            .alert("This will upload a copy of your favourites to the cloud that can be retrieved at a later time. This will overwrite any previous backup.", isPresented: $viewModel.tappedCloudBackup) {
                
                Button("Confirm") {
                    Task {
                        await viewModel.backupFavourites(context: viewContext, uid: authController.currentUser?.id ?? "")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            viewModel.backupSuccessful = false
                            viewModel.backupFailed = false
                        }
                    }
                    
                }
                Button("Cancel", role: .cancel) {
                    viewModel.tappedCloudBackup = false
                }
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
