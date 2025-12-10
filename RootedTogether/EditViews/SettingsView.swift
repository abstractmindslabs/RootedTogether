//
//  SettingsView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/11/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var user: User
    @State var name: String
    @State var gardenCode: String
    var body: some View {
        NavigationStack{
            VStack{
                Text("Settings").background(.back1).font(Font.largeTitle.bold())
                
                VStack{
                    Text("Name:").font(Font.title2).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10)
                    TextField("Name", text: $name).padding(15).glassEffect()
                }.padding(20)
                VStack{
                    Text("Garden Code:").font(Font.title2).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 10)
                    TextField("Garden Code:", text: $gardenCode).padding(15).glassEffect()
                }.padding(20)
                Button("Update"){
                    Task{
                        await user.setPersonData(name: name, garden: user.person.garden, gardenCode: gardenCode)
                    }
                }.padding(15).background(.back2).cornerRadius(20).foregroundColor(.black)
        
                
                NavigationLink("Edit Garden"){
                    GardenEdit(user: user)
                }.padding(15).background(.back2).cornerRadius(20).foregroundColor(.black)
                
                
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.back1)
            
        }
    }
}

#Preview {
    let sampleUser = User()
    sampleUser.person.id = "OxDcgxJwh3TLcC8kZPI8AhwRXbH2"
    return SettingsView(name: "Wells", gardenCode: " ").environmentObject(sampleUser)
}
