//  SettingsView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

// View for managing app settings such as appearance and backups.
struct SettingsView: View {
    
    // Retrieve appearance mode from AppStorage and manage it within the app.
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @Environment(\.managedObjectContext) private var viewContext // Core Data context for data operations.
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    @StateObject var viewModel = SettingsViewModel() // View model to handle settings logic.
    
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                // Section for appearance settings.
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode) // Show and tag appearance mode options.
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Use segmented picker for appearance options.
                }
                
                // Section for backup options.
                Section {
                    // Button to check and view backup.
                    Button() {
                        Task {
                            let proceed = await viewModel.checkForBackup(uid: authController.currentUser?.id ?? "")
                            if proceed {
                                viewModel.showSheet = true
                            }
                        }
                    } label: {
                        Text("View backup")
                    }
                    
                    // Button to restore favourites from the cloud.
                    Button() {
                        viewModel.tappedRestore = true
                    } label: {
                        HStack {
                            Text("Restore favourites from cloud")
                            Spacer()
                            Image(systemName: "icloud.and.arrow.down.fill") // Cloud restore icon.
                        }
                    }
                    
                    // Button to delete backup from the cloud.
                    Button() {
                        viewModel.tappedDelete = true
                    } label: {
                        HStack {
                            Text("Delete favourites backup from cloud")
                            Spacer()
                            Image(systemName: "trash.fill") // Trash icon for deletion.
                        }
                        .foregroundStyle(.red) // Highlight delete option in red.
                    }
                } header: {
                    Text("Backup")
                }
                
                Section {
                    Button() {
                        authController.signOut()
                        navigationController.path.removeLast()
                        navigationController.currentTab = .map
                    } label: {
                        Text("Signout")
                    }
                }
                header: {
                    Text("Signout")
                }
                
                // Show loading indicator if a task is in progress.
                if(viewModel.isLoading) {
                    ProgressView()
                }
                
                // Display status message for backup operations.
                if(!viewModel.statusMessage.isEmpty) {
                    Text(viewModel.statusMessage)
                        .foregroundStyle(viewModel.isSuccessful ? .green : .red) // Color based on success or failure.
                }
            }
        }
        .navigationTitle("Settings") // Set the navigation title to "Settings".
        
        // Alert for restoring favourites.
        .alert("Are you sure? This will overwrite your current favourites.", isPresented: $viewModel.tappedRestore) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") {
                Task {
                    await viewModel.restoreBackup(context: viewContext, uid: authController.currentUser?.id ?? "")
                }
            }
        }
        
        // Alert for deleting the backup.
        .alert("Are you sure? This will delete your favourites backup from the cloud.", isPresented: $viewModel.tappedDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") {
                Task {
                    await viewModel.deleteBackup(uid: authController.currentUser?.id ?? "")
                }
            }
        }
        
        // Alert when no backup is found.
        .alert("No backup found. Upload a backup via the favourites menu.", isPresented: $viewModel.noBackup) {
            Button("Ok", role: .cancel) {viewModel.noBackup = false}
        }
        
        // Alert for network errors.
        .alert("Network error. Try again.", isPresented: $viewModel.networkError) {
            Button("Ok", role: .cancel) {viewModel.networkError = false}
        }
        
        // Display the backup sheet when needed.
        .sheet(isPresented: $viewModel.showSheet) {
            BackupView(showSheet: $viewModel.showSheet) // Show backup sheet view.
        }
    }
}

// Enum for managing appearance modes (light, dark, or system default).
enum AppearanceMode: String, CaseIterable, Identifiable {
   case light, dark, system
   var id: String { rawValue }
}

// Preview for testing SettingsView.
#Preview {
    SettingsView()
}
