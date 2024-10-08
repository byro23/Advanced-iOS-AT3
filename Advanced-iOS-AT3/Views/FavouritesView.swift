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
    
    
    var body: some View {
        VStack {
            
        }
        .navigationTitle("Favourites")
    }
}
