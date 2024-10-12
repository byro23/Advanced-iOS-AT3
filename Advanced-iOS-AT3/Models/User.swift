//
//  User.swift
//  Advanced-iOS_AT2
//
//  Created by Byron Lester on 3/9/2024.
//

import Foundation

// Lightweight user model. Used to track favourites between different users.
struct User: Identifiable, Codable {
    let id: String
    var email: String
    
}
