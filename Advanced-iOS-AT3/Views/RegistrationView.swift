//
//  RegisterView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 12/10/2024.
//

import SwiftUI

// MARK: - RegistrationView
struct RegistrationView: View {
    
    // MARK: - Properties
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var navigationController: NavigationController
    @StateObject var viewModel = RegistrationViewModel()
    
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .trailing) {
                    InputView(text: $viewModel.email, title: "Email", placeholder: "youremail@domain.com")
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    if(!viewModel.email.isEmpty) {
                        if(viewModel.validEmail) {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                                .padding(.top, 28)
                                .padding(.trailing, 24)
                                
                        }
                        else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                                .padding(.top, 28)
                                .padding(.trailing, 24)
                        }
                    }
                }
                
                ZStack(alignment: .trailing) {
                    InputView(text: $viewModel.password, title: "Password", placeholder: "Enter a password", isSecuredField: true)
                    
                    if(!viewModel.password.isEmpty) {
                        if(viewModel.password.count > 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                                .padding(.top, 28)
                                .padding(.trailing, 24)
                        }
                        else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                                .padding(.top, 28)
                                .padding(.trailing, 24)
                        }
                    }
                }
                
                // Password confirmation field
                ZStack(alignment: .trailing) {
                    InputView(text: $viewModel.confirmPassword, title: "Confirm Password", placeholder: "Re-enter your password", isSecuredField: true)
                    
                    if(!viewModel.confirmPassword.isEmpty) {
                        if(viewModel.password == viewModel.confirmPassword) {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                                .padding(.top, 28)
                                .padding(.trailing, 24)
                        }
                        else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                                .padding(.top, 28)
                                .padding(.trailing, 24)
                        }
                    }
                }
                
                if(authController.authenticationState == .authenticating) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
                else if(authController.authenticationState == .unauthenticated) {
                    Button {
                        Task {
                            await authController.signUp(email: viewModel.email, password: viewModel.password)
                        }
                        if(authController.authenticationState == .authenticated) {
                            navigationController.path.append(NavigationController.AppScreen.User)
                        }
                        
                    } label: {
                        Text("Sign up")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .disabled(!viewModel.isValid)
                    .opacity(viewModel.isValid ? 1.0 : 0.5)
                }
                else {
                    Text("Registration successful! Redirecting...")
                        .font(.headline)
                }
                
                Spacer()
                
                
            }
            .alert("Email already exists. Please try again.", isPresented: $authController.emailAlreadyExists) {
                Button("Ok", role: .cancel) {
                    authController.emailAlreadyExists = false
                }
            }
            .navigationTitle("Registration")
            .onChange(of: authController.authenticationState) { _, newState in
                if(newState == .authenticated) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // Code to run after 3 seconds
                        navigationController.path.removeLast()
                        navigationController.path.append(NavigationController.AppScreen.User)
                    }
                }
            }
        }
        
        
    }
}
