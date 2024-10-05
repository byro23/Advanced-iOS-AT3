//
//  SearchQuery+CoreDataClass.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 5/10/2024.
//
//

import Foundation
import CoreData

@objc(SearchQuery)
public class SearchQuery: NSManagedObject {

}

extension SearchQuery {
    static func mock(context: NSManagedObjectContext) -> SearchQuery {
        let searchQuery = SearchQuery(context: context) // Create a new SearchQuery in the provided context
        searchQuery.queryText = "Mock Query"            // Set mock data for the query text
        searchQuery.date = Date()                       // Set the current date as a mock date
        searchQuery.latitude = -33.8688                 // Mock latitude (Sydney)
        searchQuery.longitude = 151.2093                // Mock longitude (Sydney)
        return searchQuery
    }
}
