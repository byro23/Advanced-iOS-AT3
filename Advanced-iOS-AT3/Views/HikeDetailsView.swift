//
//  HikeDetailsView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 6/10/2024.
//

import SwiftUI

struct HikeDetailsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel: HikeDetailsViewModel
    // @State var hike: Hike
    
    init(hike: Hike) {
        _viewModel = StateObject(wrappedValue: HikeDetailsViewModel(hike: hike))
    }
    
    var body: some View {
        VStack{
            
            AsyncImage(url: viewModel.hike.imageURL) { image in
                image
                    .resizable()  // Make the image resizable
                    .scaledToFit() // Maintain aspect ratio within the frame
            } placeholder: {
                ProgressView()  // Show a placeholder while loading
            }
            .frame(width: 100, height: 100)
            .padding()
            
            HStack {
                Text(viewModel.hike.title ?? "Unknown place.")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Button {
                    if(viewModel.isFavourite) {
                        viewModel.removeFromFavourite(context: viewContext)
                    }
                    else {
                        viewModel.addToFavourites(context: viewContext)
                    }
                    
                } label: {
                    Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                        .resizable()
                        .foregroundStyle(viewModel.isFavourite ? .red : .gray)
                        .frame(width: 30, height: 30)
                        .padding()
                }
                
            }
            
            
            Divider()
            
            HStack {
                Text("Address: ")
                    .fontWeight(.bold)
                
                Text(viewModel.hike.address ?? "Unknown address")
            }
            .padding()
            
            HStack {
                
                Text("Latitude: ")
                    .fontWeight(.bold)
                
                Text(String(format: "%.3f", viewModel.hike.coordinate.latitude))
                
                Text("Longitude: ")
                    .fontWeight(.bold)
                
                Text(String(format: "%.3f", viewModel.hike.coordinate.longitude))
            }
            .padding()
            
            HStack {
                Text("Rating")
                    .fontWeight(.bold)
                
                StarView(rating: Double(viewModel.hike.rating))
                
            }
            
            Text("(Based on \(viewModel.hike.userRatingsTotal) user ratings)")
            
            Text(viewModel.hike.summary ?? "No summaries of this hike.")
                .padding()
            
            
            
            Spacer()
        }
        .onAppear {
            viewModel.checkIfFavourite(context: viewContext)
        }
        
    }
}

#Preview {
    HikeDetailsView(hike: Hike.mock_hike)
}
