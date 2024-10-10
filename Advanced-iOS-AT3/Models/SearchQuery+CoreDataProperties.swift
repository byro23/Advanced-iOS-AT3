//
//  SearchQuery+CoreDataProperties.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//
//

import Foundation
import CoreData


extension SearchQuery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchQuery> {
        return NSFetchRequest<SearchQuery>(entityName: "SearchQuery")
    }

    @NSManaged public var date: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var queryText: String?

}

extension SearchQuery : Identifiable {

}
