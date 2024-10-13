//
//  LandingView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 12/10/2024.
//

import SwiftUI

// MARK: - LandingView
struct LandingView: View {
    // MARK: - Properties
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var navigationController : NavigationController
    @StateObject var viewModel = LandingViewModel()
    
    // MARK: - View
    var body: some View {
        VStack {
            
            HeaderView()
            
            // Email Input
            InputView(text: $viewModel.email, title: "Email", placeholder: "")
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            // Password input
            InputView(text: $viewModel.password, title: "Password", placeholder: "", isSecuredField: true)
            
            // Check if authController is authenticating user
            if authController.authenticationState != .authenticating {
                Button {
                    Task {
                        await authController.signIn(email: viewModel.email, password: viewModel.password)
                        if(authController.authenticationState == .authenticated) {
                            viewModel.email = ""
                            viewModel.password = ""
                            
                            navigationController.path.append(NavigationController.AppScreen.User)
                        }
                        else {
                            viewModel.isInvalid = true
                        }
                    }
                } label: {
                    Text("Sign in")
                    
                }
                .disabled(!viewModel.isValid)
            }
            else {
               ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            
            // Button to RegistrationView
            Button {
                navigationController.path.append(NavigationController.AppScreen.Register)
            } label: {
                HStack {
                    Text("Haven't got an account?")
                        .foregroundStyle(.gray)
                    Text("Signup")
                        .fontWeight(.bold)
                }
            }
            .padding()
            .alert("Invalid email and/or password. Try again.", isPresented: $viewModel.isInvalid) {
                Button("Ok", role: .cancel) {
                    viewModel.isInvalid = false
                }
            }
            
        }
        
    }
}
