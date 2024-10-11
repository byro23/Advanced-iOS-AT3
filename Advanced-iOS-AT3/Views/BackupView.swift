//
//  BackupView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import SwiftUI

struct BackupView: View {
    @Binding var showSheet: Bool
    
    @StateObject var viewModel: BackupViewModel = BackupViewModel()
    
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                if(viewModel.isLoading) {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                else {
                    List {
                        
                        ForEach(viewModel.favouriteHikes) { favouriteHike in
                            BackupRow(favourite: favouriteHike)
                        }
                    }
                }
            }
            .navigationTitle("Favourites Backup")
            .onAppear {
                Task {
                    await viewModel.fetchFavourites()
                }
                
            }
        }
        
    }
}

