//
//  GardenSignUp.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/2/25.
//

import SwiftUI

struct GardenSignUpView: View {
    @Environment(\.dismiss) private var dismiss
    //sign up stuff
    @State private var name: String = ""
    @State private var email: String = ""
    
    //secondary view triggers
    @State private var ShowAgreement: Bool = false
    @State private var ShowGardenIDs: Bool = false
    
    //Id generation
    @State private var gardenGen: String = ""
    @State private var editGardenGen: String = ""
    
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    @EnvironmentObject var garden: Garden
    
    //error message
    @State private var Error: String = ""
    var body: some View {
        NavigationStack{
            //collect information
            VStack {
                
                Text("Rooted Together").font(.largeTitle).foregroundStyle(.fore1).bold(true)
                Text("Garden Sign Up").font(.title).foregroundColor(.fore1).bold(true)
                //garden name text entry
                TextField("Garden Name", text: $name).keyboardType(.emailAddress)
                    .autocapitalization(.none)  // prevent iOS from capitalizing
                    .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding(15).cornerRadius(15).border(.back2, width: 3).cornerRadius(5)
                //email text entry just for contackting the ower..?maybe?
                TextField("Admin Email", text: $email).keyboardType(.emailAddress)
                    .autocapitalization(.none)  // prevent iOS from capitalizing
                    .disableAutocorrection(true).font(.title2).foregroundColor(.fore1).padding(15).cornerRadius(15).border(.back2, width: 3).cornerRadius(5)
                //
                Text("Coordinates are used for weather data collection").foregroundColor(.fore1)
                TextField("Latitude", text: $latitude).keyboardType(.numberPad)
                    .autocapitalization(.none)  // prevent iOS from capitalizing
                    .disableAutocorrection(true).font(.title3).foregroundColor(.fore1).padding(15).cornerRadius(15).border(.back2, width: 3).cornerRadius(5)
                TextField("Longitude", text: $longitude).keyboardType(.numberPad)
                    .autocapitalization(.none)  // prevent iOS from capitalizing
                    .disableAutocorrection(true).font(.title3).foregroundColor(.fore1).padding(15).cornerRadius(15).border(.back2, width: 3).cornerRadius(5)
                
                //sign up botton checks if there is a name and makes uuid
                Button("SIGN Up Garden"){
                    if name == "" || email == ""{
                        Error="Please fill out all fields"
                    }else if name.count < 5{
                        Error="Garden Name must be 5 characters or more"
                    }else if !email.contains("@") || !email.contains("."){
                        Error="Email does not appear correct"
                    }
                    else{
                        
                        
                        
                        gardenGen=self.buildGardenID(name: name)
                        editGardenGen=self.buildGardenEditCode()
                        ShowAgreement=true
                    }
                    
                    
                }.font(.title2).padding().background(.back2).cornerRadius(25).foregroundColor(.fore2).bold()
                Text(Error).foregroundColor(.red)
                
                
                //Text(user.SignedInUser.description)
                
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(.back1).fullScreenCover(isPresented: $ShowGardenIDs){
                
                //gives user the information to add garden to account
                VStack{
                    Text("Take Screen Shot").font(.largeTitle.bold()).padding().foregroundColor(.fore1)
                    Text("These IDs let users connect to garden and can be used to give out edit accses to users").foregroundColor(.red)
                    VStack{
                        Text("Garden Code: ").font(Font.title.bold()).foregroundColor(.fore2)
                        Text(gardenGen).font(Font.title2.bold()).foregroundColor(.fore2)
                        Text("Used to link user to garden")
                        Text("Garden Edit Code: ").font(Font.title.bold()).foregroundColor(.fore2)
                        Text(editGardenGen).font(Font.title2.bold()).foregroundColor(.fore2)
                        Text("Used to edit garden")
                    }.padding(20).background(.back2).cornerRadius(15)
                    Button("Done"){
                        Task{
                            await garden.makeGarden(gardenName: name, gardenCode: gardenGen, editCode: editGardenGen, latitude: Double(latitude) ?? 30, longitude: Double(longitude) ?? -102)
                            ShowAgreement=false
                            ShowGardenIDs=false
                            dismiss()
                        }
                        
                        
                        
                    }.foregroundColor(.fore1)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(.back1)
            }.sheet(isPresented: $ShowAgreement){
                VStack{
                    Text("Confirm Information").font(Font.title.bold()).padding().foregroundColor(.fore2)
                    Text("This data will be used to create a garden and is perminate. Please read though data and ensure you want to sign up a garden.").foregroundColor(.fore2)
                    
                    VStack{
                        Text("Name: \(name)")
                        Text("Email: \(email)")
                    }.foregroundColor(.fore1).padding(20).background(.back1).cornerRadius(15)
                    Button("Confirm Information"){
                        ShowGardenIDs=true
                    }.foregroundColor(.fore1).padding(20).background(.back1).cornerRadius(15)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).padding().background(.back2)
                
                
                
            }
        }
    }
    private func buildGardenID(name: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let custom = name.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression) + "-" + formatter.string(from: Date())
        
        return custom
    }
    private func buildGardenEditCode() -> String{
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).compactMap { _ in characters.randomElement() })
    }
}






#Preview {
    GardenSignUpView()
}
