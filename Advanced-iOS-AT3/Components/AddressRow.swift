//
//  AddressRow.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import SwiftUI

struct AddressRow: View {
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
