//
//  LoginView.swift
//  NPC
//
//  Created by Nguyen Le on 9/1/22.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @StateObject var userViewModel : UserViewModel = UserViewModel()
    @State var loginStatusMessage = ""
    @State var alert = false
    @State var loginSuccess = false
    @State private var isSecured: Bool = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                NavigationLink("", destination: UploadView(), isActive: self.$loginSuccess)
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    if isLoginMode {
                        Button {
                        } label: {
                            Image("transition")
                                .font(.system(size: 64))
                                .padding()
                        }
                    }
                    
                    if !isLoginMode {
                        Button {
                        } label: {
                            Image("transition")
                                .font(.system(size: 64))
                                .padding()
                        }
                    }
                    
                    Capsule()
                    /* #f5f5f5 */
                        .foregroundColor(Color(red: 0.9608, green: 0.9608, blue: 0.9608))
                        .frame(width: 380, height: 50)
                        .padding(0)
                        .overlay(
                            HStack {
                                Image(systemName: "envelope")
                                    .resizable()
                                    .frame(width: 36, height: 24, alignment: .trailing)
                                    .offset(x: 20, y: 0)
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .offset(x: 40, y: 0)
                            }
                            
                        )
                        .padding()
                    
                        .autocapitalization(.none)
                    Capsule()
                    /* #f5f5f5 */
                        .foregroundColor(Color(red: 0.9608, green: 0.9608, blue: 0.9608))
                        .frame(width: 380, height: 50)
                        .padding(0)
                        .overlay(
                            HStack {
                                Image(systemName: "l  ock")
                                    .resizable()
                                    .frame(width: 20, height: 30, alignment: .trailing)
                                    .offset(x: 25, y: 0)
                                // TODO: ADD "eye.slash.fill" : "eye.fill" when show/ hide password
                                SecureField("Password", text: $password)
                                    .offset(x: 60, y: 0)
                            }
                        )
                        .padding(12)
                        .background(Color.white)
                    
                    Button {
                        handleAction()
                        // TODO: Navigate to preference page after click create Account button
                        if let errorMessage = self.validView() {
                            print(errorMessage)
                            return
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color(red: 1, green: 0.4902, blue: 0.3216))
                    }
                    .padding(0)
                    .frame(width: 380, height: 50)
                }
            }
            
            .alert(isPresented: self.$alert, content: {
                Alert(title: Text("Error"), message: Text(self.loginStatusMessage))
            })
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.005))
                .ignoresSafeArea())
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.alert = true
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            self.userViewModel.userLogin()
            self.loginSuccess = true
        }
    }
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.alert = true
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            self.userViewModel.user = Users(uuid: result?.user.uid ?? "", email: self.email, userName: "", profilePic: "", favoriteTopics: ["Technology", "Art", "Love"], uploadedList: [])
            self.userViewModel.addUser()
            self.userViewModel.userSettings.uuid = result?.user.uid ?? ""
            self.loginSuccess = true
        }
    }
    
    // MARK: Email validation
    private func validView() -> String? {
        if email.isEmpty {
            return "Email cannot be empty"
        }
        
        if !self.isValidEmail(email) {
            return "Email is invalid"
        }
        
        return nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
