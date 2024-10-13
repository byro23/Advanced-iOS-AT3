//
//  LandingViewModel.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 12/10/2024.
//

import Foundation

// Stores the properties and validation logic required to login
class LandingViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var isInvalid = false
    
    var isValid: Bool {
        return email.contains("@") && password.count > 5
    }
    
    
}
