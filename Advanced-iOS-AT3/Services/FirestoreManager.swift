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
    func addDocument<T: Encodable>(object: T, toCollection collection: String, forUser uid: String) throws {
        let collectionRef = db.collection(collection)
        
        do {
            try collectionRef.addDocument(from: object) { error in
                if let error = error {
                    print("Error adding \(T.self) for \(uid) to Firestore: \(error.localizedDescription)")
                } else {
                    print("\(T.self) added successfully")
                }
            }
        } catch let error {
            print("Error adding \(T.self) for \(uid) to Firestore: \(error.localizedDescription)")
        }
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


