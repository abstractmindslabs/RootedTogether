//
//  SwiftUIView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    
    
    @State private var password: String = ""
    
    
    
    @EnvironmentObject var user: User
    var body: some View {
        NavigationStack{
            VStack {
                
                Text("Rooted Together").font(.largeTitle).foregroundStyle(.fore1).bold(true)
                Text("Sign In").font(.title).foregroundColor(.fore1).bold(true)
                //email
                TextField("Email", text: $email).keyboardType(.emailAddress)
                    .autocapitalization(.none)  // prevent iOS from capitalizing
                    .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                
                //test version to see password
                SecureField("Password", text: $password).autocapitalization(.none)  // prevent iOS from capitalizing
                    .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding().glassEffect().autocorrectionDisabled(true).autocapitalization(.none)
                
                
                //password
         
                Button("Sign In"){
                    Task {
                        await user.signInUser(email: email, password: password)
                    }
                    
                    
                }.font(.title2).padding().background(.back2).cornerRadius(25).foregroundColor(.fore2).bold()
                NavigationLink("Sign Up"){
                    
                SignUpView()
                    
                }.padding(10).foregroundColor(.fore1)
                
                NavigationLink("Garden Sign Up"){
                    
                GardenSignUpView()
                    
                }.padding(10).foregroundColor(.fore1)
                

                
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(.back1)
        }
    }
}


#Preview {
    @StateObject var user: User = User()
    @StateObject var garden: Garden = Garden(user: user)
    SignInView().environmentObject(garden).environmentObject(user)
}
