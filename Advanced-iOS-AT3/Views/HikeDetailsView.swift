//
//  HikeDetailsView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 6/10/2024.
//

import SwiftUI

struct HikeDetailsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel: HikeDetailsViewModel = HikeDetailsViewModel()
    @State var hike: Hike
    var body: some View {
        VStack{
            
            
            
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
