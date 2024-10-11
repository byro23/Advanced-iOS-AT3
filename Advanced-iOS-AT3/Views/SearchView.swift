//  SearchView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

// View for searching addresses or regions with debounced text input and results display.
struct SearchView: View {
    
    @FocusState private var isFocusedTextField: Bool // State for managing text field focus.
    
    @StateObject var viewModel = SearchViewModel() // View model to handle search logic and results.
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                HeaderView() // Custom header for the search view.
                    .padding()
                
                // Text field for address or region input.
                TextField("Type address or region: ", text: $viewModel.searchableText)
                    .padding()
                    .autocorrectionDisabled() // Disable autocorrection for address input.
                    .focused($isFocusedTextField) // Bind focus state to control keyboard behavior.
                    .font(.title) // Use title font size for the text field.
                    .onReceive( // Debounce input to limit search frequency.
                        viewModel.$searchableText.debounce(
                            for: .seconds(1),
                            scheduler: DispatchQueue.main
                        )
                    ) {
                        viewModel.searchAddress($0) // Trigger address search on debounced input.
                    }
                    .background(Color(.systemBackground)) // Set background color for the text field.
                    .overlay {
                        ClearButton(text: $viewModel.searchableText) // Add a clear button for text field.
                            .padding(.trailing)
                            .padding(.top, 8)
                    }
                    .onAppear {
                        isFocusedTextField = true // Automatically focus the text field when the view appears.
                    }
                
                // List to display search results.
                List(self.viewModel.results) { address in
                    AddressRow(address: address) // Custom row for each address result.
                        .listRowBackground(backgroundColor) // Set the background color for list rows.
                }
                .listStyle(.plain) // Use a plain list style.
                .scrollContentBackground(.hidden) // Hide default background behind list content.
            }
            .background(backgroundColor) // Set background color for the view.
            .edgesIgnoringSafeArea(.bottom) // Extend background to edges, including under the safe area.
        }
    }
    
    var backgroundColor: Color = Color(.systemGray6) // Define background color for the view.
}

// Preview for testing SearchView.
#Preview {
    SearchView()
}
