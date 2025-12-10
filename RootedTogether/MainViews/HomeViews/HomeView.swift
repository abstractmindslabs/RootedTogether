//
//  HomeView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var garden: Garden
    //temp
    @State var gardenHealth: Float = 0.9267
    var body: some View {
        NavigationStack{
            
            ScrollView {
                Text("Hello, \(user.person.name)").font(.largeTitle.bold()).padding().frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.fore1)
                
                //health
                ZStack{
                    Circle().trim(from: 0, to: 0.75).stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 35, lineCap: .round)).rotationEffect(.degrees(-225)).frame(width: 200)
                    Circle().trim(from: 0, to: CGFloat(gardenHealth*0.75))
                        .stroke(gardenHealth > 1/3 ? (gardenHealth > 2/3 ? .colorMeterGreen : .colorMeterYellow) : .colorMeterRed,
                                style: StrokeStyle(lineWidth: 35, lineCap: .round)).rotationEffect(.degrees(-225)).frame(width: 200).shadow(radius: 10)
                    Text(String(round(gardenHealth*1000)/10) + "%").font(.system(size: 30, weight: .bold, design: .default))
                }
                Spacer()
                VStack{
                    
                    
                        HStack{
                            Text("Name").font(.title.bold()).foregroundColor(.fore1)
                            Spacer()
                            Text("Plants Helped").font(.title.bold()).foregroundColor(.fore1)
                            
                            
                            
                            
                        }.padding(20)
                        
                        ForEach(Array(user.contributions.enumerated()), id: \.element.id){index, contribution in
                            //Text(user.contributions.count)
                            let isPerson: Bool = user.person.id == contribution.id
                            HStack{
                                
                                Text(contribution.name).font(.title2.bold()).foregroundColor(isPerson ? .colorYouText : .colorOtherPersonText )
                                Spacer()
                                                             Text(String(contribution.count)).font(.title2.bold()).foregroundColor(isPerson ? .colorYouText : .colorOtherPersonText )
                                
                                
                                
                            }.padding(10).background(isPerson ? .colorLearderboardBackgroundYou : .clear).cornerRadius(20).padding(5)
                        }
                        
                        if !user.TopFive {
                            HStack{
                                
                                Text(user.PersonalContribution.name).font(.title2.bold()).foregroundColor(.colorYouText)
                                Spacer()
                                Text(String(user.PersonalContribution.count)).font(.title2.bold()).foregroundColor(.colorYouText)
                            }.padding(10).background(.colorLearderboardBackgroundYou).cornerRadius(20).padding(5)
                        }
                        
                        
                            
                        Spacer()

                    } .background(.colorLeaderboard).cornerRadius(20).padding(15)
                
                Spacer()
                

                            }.toolbar{//toolbar with options
                                ToolbarItem(placement: .navigationBarTrailing){
                                    Menu("Profile", systemImage: "person.circle"){
                                        NavigationLink(){
                                            SettingsView(name: user.person.name, gardenCode: user.person.gardenCode)
                                        }label: {
                                            // The label is what the user sees and taps
                                            Image(systemName: "gearshape.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.yellow)
                                            Text("Settings")
                                        }
                                        Button("Sign Out", systemImage: "arrow.backward.circle"){
                                            user.signOutUser()
                                        }
                        
                        
        
                        
                    }
                }
                            }.background(.back1).onAppear(perform: {
                        
                                Task{
                                    try await garden.RunSimulation()
                                }
                                
                            })
        }
    }
}

#Preview {
    @StateObject var user: User = User()
    user.person.id = "OxDcgxJwh3TLcC8kZPI8AhwRXbH2"
    user.person.garden = "TestGarden"
    @StateObject var garden: Garden = Garden(user: user)
    return HomeView().environmentObject(garden).environmentObject(user)
    
}
