//
//  FavouritesView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 8/10/2024.
//

import SwiftUI

struct FavouritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = FavouritesViewModel()
    
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
                    Text("No favourite hikes found.")
                        .font(.headline)
                        .padding()
                }
                else {
                    List {
                        ForEach(favouriteHikes) { hike in
                            HikeRow(hike: hike)
                                .onTapGesture {
                                    
                                }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
            }
            .navigationTitle("Favourites")
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
