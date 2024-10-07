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
    @State var hike: Hike
    
    init(hike: Hike) {
        self.hike = hike
        _viewModel = StateObject(wrappedValue: HikeDetailsViewModel(hike: hike))
    }
    
    var body: some View {
        VStack{
            
            AsyncImage(url: hike.imageURL) { image in
                image
                    .resizable()  // Make the image resizable
                    .scaledToFit() // Maintain aspect ratio within the frame
            } placeholder: {
                ProgressView()  // Show a placeholder while loading
            }
            .frame(width: 150, height: 150)
            .padding()
             
            Text(hike.title ?? "Unknown place.")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Divider()
            
            HStack {
                Text("Address: ")
                    .fontWeight(.bold)
                
                Text(hike.address ?? "Unknown address")
            }
            .padding()
            
            HStack {
                
                Text("Latitude: ")
                    .fontWeight(.bold)
                
                Text("\(hike.coordinate.latitude)")
                
                Text("Longitude: ")
                    .fontWeight(.bold)
                
                Text("\(hike.coordinate.longitude)")
            }
            .padding()
            
            HStack {
                Text("Rating")
                    .fontWeight(.bold)
                
                Text("\(hike.rating)")
            }
            
            Text(hike.summary ?? "No summaries of this hike.")
                .padding()
            
            
            
            Spacer()
        }
        
    }
}

#Preview {
    HikeDetailsView(hike: Hike.mock_hike)
}
