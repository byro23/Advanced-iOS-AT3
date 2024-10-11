//
//  FirestoreManager.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//

import Foundation
import FirebaseFirestore

// Stores the collection name
enum FireStoreCollection: String {
    case favourites = "favourites"
}

// Manages requests to Google Firestore Database
class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    
    // Generic function to add any Encodable object to Firestore
    func addDocument(docData: [String: Any], toCollection collection: String) async throws {
        let collectionRef = db.collection(collection)
        
        do {
            try await collectionRef.addDocument(data: docData)
        }
        catch {
            try await deleteCollection(collection)
        }
        
    }
    
    func deleteCollection(_ collectionRef: String) async throws {
        // Get all documents in the collection
        let collectionRef = db.collection(collectionRef)
        let documents = try await collectionRef.getDocuments()

        // Iterate through each document and delete it
        for document in documents.documents {
            try await document.reference.delete()
        }
        
    }
    
    
    // Function to fetch documents from the "favourites" collection
    func fetchFavourites() async throws -> [[String: Any]] {
            // Reference to the "favourites" collection
            let collectionRef = db.collection("favourites")
            
            // Fetch the documents in the collection
            let querySnapshot = try await collectionRef.getDocuments()
            
            // Map the documents to FavouriteHikes objects
            let favourites = querySnapshot.documents.map { document in
                document.data()
            }
            
            // Return the array of FavouriteHikes
            return favourites
        }
    
}


