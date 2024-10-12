//
//  AddressRow.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

// MARK: - View
struct AddressRow: View { // Used to show the address results as part of the search auto-complete
    let address: AddressResult
        
    var body: some View {
        NavigationLink {
            MapView()
        } label: {
            VStack(alignment: .leading) {
                Text(address.title)
                Text(address.subtitle)
                    .font(.caption)
            }
        }
        .padding(.bottom, 2)
    }
}

#Preview {
    AddressRow(address: AddressResult.MOCK_ADDRESS)
}
