//
//  NavigationController.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import Foundation
import SwiftUI

// Manages the app navigation with the Navigation Stack and Tabview
class NavigationController: ObservableObject {
    
    // Contains the one view which gets popped to the Nav stack
    enum AppScreen: Hashable {
        case HikeDetails(hike: Hike)
        case Register
        case User
    }
    
    // The different tabs
    enum Tab {
        case map
        case favourites
        case settings
    }
    
    @Published var path = NavigationPath()
    @Published var currentTab = Tab.map
}
