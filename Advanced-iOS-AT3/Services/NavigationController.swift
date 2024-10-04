//
//  NavigationController.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 2/10/2024.
//

import Foundation
import SwiftUI

class NavigationController: ObservableObject {
    
    enum AppScreen {
        
    }
    
    enum Tab {
        case map
        case pay
        case transactions
        case categories
    }
    
    @Published var path = NavigationPath()
    @Published var currentTab = Tab.map
}
