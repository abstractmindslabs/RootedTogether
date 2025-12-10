//
//  SignUpView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct SignUpView: View {

    
    @State private var name: String = ""
    @State private var garden: String = ""
    
    @State private var email: String = ""
    
    @State private var password: String = ""
    @State private var password2: String = ""
    
    @State private var Error: String = ""
    
    
    
    @EnvironmentObject var user: User
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack {
                    
                    Text("Rooted Together").font(.largeTitle).foregroundStyle(.fore1).bold(true)
                    Text("User Sign Up").font(.title).foregroundColor(.fore1).bold(true)
                    
                    Text("-- User Info --")
                    // user and garden info
                    TextField("Name", text: $name)
                        .autocapitalization(.none)  // prevent iOS from capitalizing
                        .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                    TextField("Garden Code", text: $garden)
                        .autocapitalization(.none)  // prevent iOS from capitalizing
                        .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                    //email
                    Text("-- Account Sign Up --")
                    TextField("Email", text: $email).keyboardType(.emailAddress)
                        .autocapitalization(.none)  // prevent iOS from capitalizing
                        .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                    
                    //password
                    TextField("Password", text: $password)
                        .autocapitalization(.none)  // prevent iOS from capitalizing
                        .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                    
                    SecureField("Confirm Password", text: $password2)
                        .autocapitalization(.none)  // prevent iOS from capitalizing
                        .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                    Button("Sign UP"){
                        if password != password2{
                            Error = "Passwords do not match"
                        }else if name == "" {
                            Error = "Please add a name"
                        }else if garden == "" {
                            Error = "Please add a garden code- note: This can be created on sign up page if you are making new garden"
                            //note we need to add garden code check as well
                        }else{
                            //try sign in and see if it works
                            Task{
                                Error = await user.signUpUser(email: email, password: password)
                                if Error == "Success"{
                                //signs in new user this will also bring them to main page
                                    await user.setPersonData(name: name, garden: garden, gardenCode: "")
                                    
                                    await user.signInUser(email: email, password: password)


                                    
 
                                }
                            }
                        }
                        
                    }.font(.title2).padding().background(.back2).cornerRadius(25).foregroundColor(.fore2).bold()
                    
                    
                    Text(Error).foregroundColor(Color.red)
                    Text(user.SignedInUser.description)
                    
                    
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(.back1)
        }
    }
}

#Preview {
    @StateObject var user: User = User()
    @StateObject var garden: Garden = Garden(user: user)
    SignUpView().environmentObject(garden).environmentObject(user)
    
}
