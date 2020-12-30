//
//  newUser.swift
//  PathFinder
//
//  Created by Jaryd Meek on 11/19/20.
//

import SwiftUI
import CryptoKit


func login(user: String, pass: String) {
    
}

    struct createAccount: View {
        
        @Environment(\.presentationMode) var presentationMode
        @State private var newUser = false
        @State private var alert = false
        @State private var err = ""
        @State var user: String = ""
        @State var email: String = ""
        @State var pass: String = ""
        @State var confirmpass: String = ""
        @Binding var localUserId:Int
        @Binding var login:Bool
        
        
        func passwordHash(email: String, password: String) -> String {
            let salt = "6MgRphZeod2dbGpiRGmhroEmkj66oQVf"
            let toHash = password + "." + salt
            
            let hashed = SHA256.hash(data: Data(toHash.utf8))
            let hashString = hashed.compactMap { String(format: "%02hhx", $0) }.joined()
            return hashString
        }
        
        func validPass() -> Bool {
            let hashedPW = passwordHash(email: email, password: pass)
            let hashedCPW = passwordHash(email: email, password: confirmpass)
            
            if (hashedCPW == hashedPW) {
                return true
            }
            err = "pw"
            return false
        }
        
        func validEmail() -> Bool {
            if (email.contains("@") && email.contains(".")) {
                return true
            }
            err = "email"
            return false
        }
        
        func sendData() {
            
            let url = URL(string: "\(mainUrl)/mobile/accountCreate")
            guard let requestUrl = url else { fatalError() }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"

            
            
            let postString = "newUsername=" + user + "&newEmail=" + email + "&newPassword=" + passwordHash(email: email, password: pass)
            request.httpBody = postString.data(using: String.Encoding.utf8);
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    let response:Int = Int(dataString) ?? -1
                    if response != -1 {
                        newUser = true
                        userName = user
                        userID = response
                        localUserId = response
                        login = true
                        save()
                    }else {
                        alert = true
                        err = "user"
                    }
                    
                }
            }
            task.resume()
            
        }
        @State private var swap: Int? = 0
        func getNewUser() {
            if newUser {
                userLoggedIn = true
                self.presentationMode.wrappedValue.dismiss()
            }
        }

        var body: some View {
            
            VStack{
                if !newUser {
                    TextField("Username", text: $user)
                        .padding(15)
                        .background(Color("lightDark").opacity(0.25))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(10)
                    TextField("Email", text: $email)
                        .padding(15)
                        .background(Color("lightDark").opacity(0.25))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(10)
                    SecureField("Password", text: $pass)
                        .padding(15)
                        .background(Color("lightDark").opacity(0.25))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(10)
                    SecureField("Confirm Password", text: $confirmpass)
                        .padding(15)
                        .background(Color("lightDark").opacity(0.25))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(10)
                    Button("Create account"){
                        if (validPass() && validEmail()){
                            sendData()
                        } else {
                            alert = true
                        }
                    }
                    .padding(15)
                    .foregroundColor(Color.white)
                    .background(Color("mainColor"))
                    .font(Font.custom("Inter", size: 28))
                    .cornerRadius(5)
                }else {
                    Text("User Created!")
                    let _ = getNewUser()
                }
                
            }
            .navigationBarTitle("Create Account")
            .alert(isPresented: $alert) { () -> Alert in
                let button = Alert.Button.default(Text("OK")) {
                    
                    alert = false
                }
                if (err == "pw") {
                    return Alert(title: Text("Passwords Don't Match"), dismissButton: button)
                } else if (err == "user") {
                    return Alert(title: Text("Username or Email Already Exist"), dismissButton: button)
                } else if (err == "email") {
                    return Alert(title: Text("Please Enter A Valid Email Address"), dismissButton: button)
                }
                return Alert(title: Text("OtherError"), dismissButton: button)
            }
        }
    }


struct loginPage: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var newUser = false
    @State private var alert = false
    @State private var err = ""
    @State var user: String = ""
    @State var email: String = ""
    @State var pass: String = ""
    @State var confirmpass: String = ""
    @Binding var localUserId:Int
    @Binding var login:Bool
    
    
    func passwordHash(password: String) -> String {
        let salt = "6MgRphZeod2dbGpiRGmhroEmkj66oQVf"
        let toHash = password + "." + salt
        
        let hashed = SHA256.hash(data: Data(toHash.utf8))
        let hashString = hashed.compactMap { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
    
    func loginPost() {
        
        let url = URL(string: "\(mainUrl)/mobile/login")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        
        
        let postString = "username=" + user + "&password=" + passwordHash(password: pass)
        request.httpBody = postString.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let response:Int = Int(dataString) ?? -1
                if (response != -1 && response != -2) {
                    newUser = true
                    userName = user
                    userID = response
                    localUserId = response
                    login = true
                    save()
                }else if (response == -1) {
                    err = "user"
                    alert = true
                }else if (response == -2) {
                    err = "pass"
                    alert = true
                }
                
            }
        }
        task.resume()
        
    }
    @State private var swap: Int? = 0
    func getNewUser() {
        if newUser {
            userLoggedIn = true
            self.presentationMode.wrappedValue.dismiss()
        }
    }

    var body: some View {
        
        VStack{
            if !newUser {
                TextField("Username", text: $user)
                    .padding(15)
                    .background(Color("lightDark").opacity(0.25))
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(10)
                SecureField("Password", text: $pass)
                    .padding(15)
                    .background(Color("lightDark").opacity(0.25))
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(10)
                Button("Login"){
                    loginPost()
                }
                .padding(15)
                .foregroundColor(Color.white)
                .background(Color("mainColor"))
                .cornerRadius(5)
                .font(Font.custom("Inter", size: 28))
            }else {
                Text("User Created!")
                let _ = getNewUser()
            }
            
        }
        .navigationBarTitle("Login")
        .alert(isPresented: $alert) { () -> Alert in
            let button = Alert.Button.default(Text("OK")) {
                
                alert = false
            }
            if (err == "pass") {
                return Alert(title: Text("Invalid Password"), dismissButton: button)
            } else if (err == "user") {
                return Alert(title: Text("Invalid Username"), dismissButton: button)
            }
            return Alert(title: Text("OtherError"), dismissButton: button)
        }
    }
}



