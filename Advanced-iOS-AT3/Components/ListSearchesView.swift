//
//  ListView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 5/10/2024.
//

import SwiftUI

struct ListSearchesView: View {
    var searchQueries: [SearchQuery]
    
    var body: some View {
        VStack {
            Text("Recent searches")
                .font(.headline)
                .padding(.top)
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let viewContext = persistenceController.container.viewContext
    ListSearchesView(searchQueries: SearchQuery.mock(context: viewContext))
}
