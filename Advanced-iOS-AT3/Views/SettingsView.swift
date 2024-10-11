//
//  SettingsView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode) // Explicitly set the tag
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    Button() {
                        Task {
                            let proceed = await viewModel.checkForBackup()
                            
                            if proceed {
                                viewModel.showSheet = true
                            }
                        }
                    } label: {
                        Text("View backup")
                    }
                    
                    Button() {
                        Task {
                            await viewModel.restoreBackup(context: viewContext)
                        }
                    } label: {
                        HStack {
                            Text("Restore favourites from cloud")
                            Spacer()
                            Image(systemName: "icloud.and.arrow.down.fill")
                        }
                        
                    }
                    
                    Button() {
                        Task {
                            await viewModel.deleteBackup()
                        }
                    } label: {
                        HStack {
                            Text("Delete favourites backup from cloud")
                            Spacer()
                            Image(systemName: "trash.fill")
                        }
                        .foregroundStyle(.red)
                        
                    }
                } header: {
                    Text("Backup")
                }
                if(viewModel.isLoading) {
                    ProgressView()
                }
                
                if(!viewModel.statusMessage.isEmpty) {
                    Text(viewModel.statusMessage)
                        .foregroundStyle(viewModel.isSuccessful ? .green : .red)
                }
                
                
                

            }
        }
        .navigationTitle("Settings")
        .alert("Are you sure? This will overrite your current favourites.", isPresented: $viewModel.tappedRestore) {
            Button("Cancel", role: .cancel) {}
            
            Button("Confirm") {
                Task {
                    await viewModel.restoreBackup(context: viewContext)
                }
            }
        }
        .alert("Are you sure? This will delete your favourites backup from the cloud.", isPresented: $viewModel.tappedDelete) {
            Button("Cancel", role: .cancel) {}
            
            Button("Confirm") {
                Task {
                    await viewModel.deleteBackup()
                }
            }
            
        }
        .alert("No backup found. Upload a backup via the favourites menu.", isPresented: $viewModel.noBackup) {
            Button("Ok", role: .cancel) {viewModel.noBackup = false}
        }
        .alert("Network error. Try again.", isPresented: $viewModel.networkError) {
            Button("Ok", role: .cancel) {viewModel.networkError = false}
        }
        .sheet(isPresented: $viewModel.showSheet) {
            BackupView(showSheet: $viewModel.showSheet)
        }
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
   case light, dark, system
   var id: String { rawValue }
}


#Preview {
    SettingsView()
}
