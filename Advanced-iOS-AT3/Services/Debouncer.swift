//
//  Debouncer.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 6/10/2024.
//

import Foundation

// Used to reduce frequency of API requests
class Debouncer : ObservableObject {
    private var workItem: DispatchWorkItem?
    
    func debounce(delay: TimeInterval, action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}
