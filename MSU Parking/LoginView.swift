//
//  LoginView.swift
//  MSU Parking
//
//  Created by gopityro on 2024-11-11.
//

import SwiftUI
 
struct LoginView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginFailed: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var userRole: String? = nil
    @State private var isAdmin: Bool = false
    
    // Define the primary color
    private let primaryColor = Color(red: 209/255, green: 25/255, blue: 13/255)  // #D1190D
    
    var body: some View {
        NavigationStack {
            VStack {
                // Logo and title
                Image(systemName: "shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(primaryColor)
                    .padding(.top, 50)
                
                Text("MSU Parking")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(primaryColor)
                    .padding(.top, 10)
                
                Spacer()
                
                // Username TextField
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                
                // Password SecureField
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                
                // Toggle for Admin/User role
                Toggle(isOn: $isAdmin) {
                    Text(isAdmin ? "Admin Login" : "User Login")
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)  // Apply primary color to the label
                }
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))  // Apply primary color to the toggle
                
                // Login Button
                Button(action: login) {
                    Text("Login")
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [primaryColor, primaryColor]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                // Error message if login fails
                if loginFailed {
                    Text("Invalid credentials. Please try again.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 5)
                }
                
                Spacer()
                
                // Check if login is successful and navigate
                NavigationLink(destination: destinationView(), isActive: $isLoggedIn) {
                    EmptyView()  // Invisible trigger for navigation
                }
                .hidden()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // Dummy login logic
    private func login() {
        loginFailed = false
        // Use the isAdmin state to pass the correct role when authenticating
        let role = isAdmin ? "admin" : "user"
        
        if let user = dataManager.authenticateUser(username: username, password: password){
            // After successful login, navigate based on role
            if user.role == role {
                userRole = role
                isLoggedIn = true
            } else {
                // If the role does not match, set loginFailed to true
                loginFailed = true
                userRole = role
            }
        } else {
            // If login fails
            loginFailed = true
        }
    }
    
    // Determine which view to navigate to based on user role
    private func destinationView() -> some View {
        if userRole == "admin" {
            return AnyView(AdminView())  // Navigate to AdminView for admin users
        } else if userRole == "user" {
            return AnyView(ChooseDestinationView())  // Navigate to ChooseEntrance for regular users
        } else {
            return AnyView(Text("Unknown Role"))  // Default case, should not happen in this setup
        }
    }
}

#Preview {
    LoginView()
}
