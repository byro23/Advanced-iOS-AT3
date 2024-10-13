//
//  BackupView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 11/10/2024.
//

import SwiftUI

// MARK: - BackupView
struct BackupView: View {
    
    // MARK: - Properties
    @Binding var showSheet: Bool
    @StateObject var viewModel: BackupViewModel = BackupViewModel()
    @EnvironmentObject var authController: AuthController
    
    // MARK: - View
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
                    await viewModel.fetchFavourites(uid: authController.currentUser?.id ?? "")
                }
                
            }
        }
        
    }
}

