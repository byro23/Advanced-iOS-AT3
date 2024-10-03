//
//  AddressResult.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 3/10/2024.
//

import Foundation

struct AddressResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

extension AddressResult {
    static let MOCK_ADDRESS = AddressResult(title: "Sydney", subtitle: "NSW")
}

