//
//  FirestoreManager.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 10/10/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// Stores the collection name
enum FireStoreCollection: String {
    case favourites = "favourites"
    case users = "users"
}

// MARK: - Firebase Manager
class FirebaseManager { // Manages requests to Google Firestore Database
    // MARK: - Properties
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    // MARK: - Functions
    // Add document to collection or subcollection based on userId
    func addDocument(docData: [String: Any], toCollection collection: String, toSubCollection subCollection: String?, forUser uid: String) async throws {
        
        var collectionRef: CollectionReference

        if let subCollectionName = subCollection {
            collectionRef = db.collection(collection).document(uid).collection(subCollectionName)
        }
        else {
            collectionRef = db.collection(collection)
        }
        
        do {
            try await collectionRef.addDocument(data: docData)
        }
        catch {
            await deleteFavourites(uid: uid)
        }
        
    }
    
    // Deletes the user's favourites cloud backup
    func deleteFavourites(uid: String) async {
        // Get all documents in the collection
        let collectionRef = db.collection(FireStoreCollection.users.rawValue).document(uid).collection(FireStoreCollection.favourites.rawValue)
        
        do {
            let documents = try await collectionRef.getDocuments()
            
            // Iterate through each document and delete it
            for document in documents.documents {
                try await document.reference.delete()
            }
        }
        catch {
            print("Error: \(error.localizedDescription)")
        }
        
        
    }
    
    // Function to fetch documents from the "favourites" collection
    func fetchFavourites(uid: String) async throws -> [[String: Any]] {
            // Reference to the "favourites" collection
        let collectionRef = db.collection(FireStoreCollection.users.rawValue).document(uid).collection(FireStoreCollection.favourites.rawValue)
            
            // Fetch the documents in the collection
            let querySnapshot = try await collectionRef.getDocuments()
            
            // Map the documents to FavouriteHikes objects
            let favourites = querySnapshot.documents.map { document in
                document.data()
            }
            
            // Return the array of FavouriteHikes
            return favourites
        }
    
    // Authenticates the user using FirebaseAuth
    func authenticateUser(email:String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    // Adds user to database
    func createUser(email: String, password: String) async throws -> Bool {
        
        do {
            let emailQuerySnapshot = try await Firestore.firestore().collection(FireStoreCollection.users.rawValue).whereField("email", isEqualTo: email).getDocuments()
            
            if(!emailQuerySnapshot.isEmpty) {
                print("Email already exists")
                return false
            }
            
            
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(id: authResult.user.uid, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            
            
            try await Firestore.firestore().collection(FireStoreCollection.users.rawValue).document(user.id).setData(encodedUser)
            return true
        }
        
        catch {
            print("Failed to create user")
            return false
        }
        
    }
    
    // Fetches the user information from the database
    func fetchUser(uid: String) async -> DocumentSnapshot? {
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            return snapshot
        }
        catch {
            print("Error retrieving snapshot")
            return nil
        }
    }
    
}


