//
//  FirestoreManager.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//

import Foundation
import FirebaseFirestore


enum FireStoreCollection: String {
    case favourites = "favourites"
}

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
        
        print("All documents deleted from collection \(collectionRef.path)")
    }
    
    
    func fetchDocuments<T: Decodable>(uid: String, collectionName: String, as type: T.Type) async throws -> [T] {
        
        var documents: [T] = []
        
        let collectionRef = db.collection("users").document(uid).collection(collectionName)
                
        let querySnapshot = try await collectionRef.getDocuments()
        documents = try querySnapshot.documents.map { try $0.data(as: T.self) }
        
        return documents  // Returns empty array if error occurs
    }
    
    func deleteDocument(uid: String, collectionName: String, documentId: String) async throws {
        let documentRef = db.collection("users").document(uid).collection(collectionName).document(documentId)
        
        try await documentRef.delete()
    }
    
}


