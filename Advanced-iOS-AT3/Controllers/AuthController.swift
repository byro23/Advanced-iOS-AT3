//
//  AuthViewModel.swift
//  Advanced-iOS_AT2
//
//  Created by Byron Lester on 3/9/2024.
//

import Foundation
import Firebase
import FirebaseAuth

// Used to track the various authentication state changes that occur in a user session
enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

// MARK: - AuthController
@MainActor
class AuthController: ObservableObject { // This class is used to manage the user session
    //MARK: - Properties
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var emailAlreadyExists: Bool = false
    
    // MARK: - Functions
    
    // Authenticates the user
    func signIn(email: String, password: String) async {
        do {
            authenticationState = .authenticating
            try await FirebaseManager.shared.authenticateUser(email: email, password: password)
            print("User authenticated.")
            await fetchUser()
            authenticationState = .authenticated
        }
        catch {
            authenticationState = .unauthenticated
            print("Failed to login user.")
        }
        
        
    }
    
    // Create an account and authenticate the user
    func signUp(email: String, password: String) async {
        authenticationState = .authenticating
        
        do {
            let isEmailUnique = try await FirebaseManager.shared.createUser(email: email, password: password)
            if(isEmailUnique) {
                try await FirebaseManager.shared.authenticateUser(email: email, password: password)
                await fetchUser()
                authenticationState = .authenticated
                print("Sign up successful.")
                return
            }
            emailAlreadyExists = true
            authenticationState = .unauthenticated
        }
        catch {
            print("Error signing up: \(error)")
            authenticationState = .unauthenticated
        }
    }
    
    // Fetches authenticated user from Firestore Db
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // Retrieve user from Db
        guard let snapshot = await FirebaseManager.shared.fetchUser(uid: uid) else {
            print("Snapshot is nil")
            return
        }
        
        // Decode user
        do {
            self.currentUser = try snapshot.data(as: User.self)
        }
        catch {
            print("Error decoding user")
            print(error)
        }
    }
    
    // Sign the user out (deauthenciate)
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            authenticationState = .unauthenticated
        }
        catch {
            print("Error signing user out: \(error)")
        }
    }
    
    
}
