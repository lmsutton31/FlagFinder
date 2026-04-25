//
//  LoginView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    enum Field {
        case email, password
    }
 
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonDisabled = true
    @State private var presentSheet = false
    @FocusState private var focusField: Field?
 
    var body: some View {
        VStack(spacing: 20) {
 
            // App branding
            VStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.flagLightGreen)
                Text("FlagFinder")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.flagDarkGreen)
                Text("Rank the courses you've played!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
 
            // Email & password fields - same as Snacktacular
            Group {
                TextField("email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focusField, equals: .email)
                    .onSubmit {
                        focusField = .password
                    }
                    .onChange(of: email) {
                        enableButtons()
                    }
 
                SecureField("password", text: $password)
                    .submitLabel(.done)
                    .focused($focusField, equals: .password)
                    .onSubmit {
                        focusField = nil
                    }
                    .onChange(of: password) {
                        enableButtons()
                    }
            }
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
 
            // Sign Up / Log In buttons - same as Snacktacular
            HStack {
                Button("Sign Up") {
                    register()
                }
                    .padding(.trailing)
                Button("Log In") {
                    login()
                }
                    .padding(.leading)
            }
            .buttonStyle(.borderedProminent)
            .tint(.flagDarkGreen)
            .font(.title2)
            .disabled(buttonDisabled)
        }
        .padding()
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            // If already logged in, go straight to main app
            if Auth.auth().currentUser != nil {
                presentSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            HomeScreenView()
        }
    }
 
    // Same logic as Snacktacular
    func enableButtons() {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passwordIsGood = password.count >= 6
        buttonDisabled = !(emailIsGood && passwordIsGood)
    }
 
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "SIGNUP ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("✅ Registration successful!")
                presentSheet = true
            }
        }
    }
 
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "LOGIN ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("✅ Login successful!")
                presentSheet = true
            }
        }
    }
}
 
#Preview {
    LoginView()
}
