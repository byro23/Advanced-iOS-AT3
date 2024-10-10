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
    
    enum AppScreen: Hashable {
        case HikeDetails(hike: Hike)
    }
    
    enum Tab {
        case map
        case favourites
        case settings
    }
    
    @Published var path = NavigationPath()
    @Published var currentTab = Tab.map
}
