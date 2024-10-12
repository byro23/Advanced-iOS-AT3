//
//  LandingView.swift
//  Advanced-iOS-AT3
//
//  Created by Byron Lester on 12/10/2024.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var navigationController : NavigationController
    @StateObject var viewModel = LandingViewModel()
    
    var body: some View {
        VStack {
            HeaderView()
            
            InputView(text: $viewModel.email, title: "Email", placeholder: "")
                .textInputAutocapitalization(.never)
                //.keyboardType(.emailAddress)
            InputView(text: $viewModel.password, title: "Password", placeholder: "", isSecuredField: true)
            
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
            }
            
            
            
            HStack {
                
                Button {
                    navigationController.path.append(NavigationController.AppScreen.Register)
                } label: {
                    Text("Haven't got an account?")
                        .foregroundStyle(.gray)
                    Text("Signup")
                        .fontWeight(.bold)
                }
            }
            .padding()
            
        }
        .alert("Invalid email and/or password. Try again.", isPresented: $viewModel.isInvalid) {
            Button("Ok", role: .cancel) {
                viewModel.isInvalid = false
            }
        }
    }
}
