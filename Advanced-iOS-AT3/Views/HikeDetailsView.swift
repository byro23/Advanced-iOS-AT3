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
            Divider()
            
            Text(hike.summary ?? "No summaries of this hike.")
                .font(.headline)
        }
        
        
    }
}

#Preview {
    HikeDetailsView(hike: Hike.mock_hike)
}
