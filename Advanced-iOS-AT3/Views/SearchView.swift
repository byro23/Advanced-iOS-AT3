//
//  SearchView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

struct SearchView: View {
    
    @FocusState private var isFocusedTextField: Bool
    
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                TextField("Type address: ", text: $viewModel.searchableText)
                    .padding()
                    .autocorrectionDisabled()
                    .focused($isFocusedTextField)
                    .font(.title)
                    .onReceive(
                        viewModel.$searchableText.debounce(
                            for: .seconds(1),
                            scheduler: DispatchQueue.main
                        )
                    ) {
                        viewModel.searchAddress($0)
                    }
                    .background(Color(.systemBackground))
                    .overlay {
                        ClearButton(text: $viewModel.searchableText)
                            .padding(.trailing)
                            .padding(.top, 8)
                    }
                    .onAppear {
                        isFocusedTextField = true
                    }
                List(self.viewModel.results) { address in
                    AddressRow(address: address)
                        .listRowBackground(backgroundColor)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(backgroundColor)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    var backgroundColor: Color = Color(.systemGray6)
}

#Preview {
    SearchView()
}
