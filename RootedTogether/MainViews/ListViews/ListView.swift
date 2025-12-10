//
//  ListView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var garden: Garden
    @Binding var SelectedTab: Int
    @Binding var selected: Int?
    @Binding var showInfo: Bool
    
    var body: some View {
        VStack{
            Text(garden.gardenName).font(Font.largeTitle.bold()).padding().foregroundColor(.fore1)
            ScrollView([.vertical]){
                
                ForEach(Array(garden.plants.enumerated()), id: \.element.id){index, plant in
                    let waterStainBar: CGFloat = CGFloat(200*plant.WaterStrain)
                    
                    Button{SelectedTab = 1
                        selected = index
                        showInfo=true} label: {
                        
                        
                        VStack{
                            
                            
                            VStack(alignment: .leading){
                                Text(plant.name).font(Font.title.bold()).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.fore1).padding(10)
                                Text("Water Strain:").foregroundColor(.fore1)
                                ZStack{
                                    Rectangle().cornerRadius(10).frame(width: 200, height: 35).foregroundColor(.black.opacity(0.1)).frame(maxWidth: .infinity, alignment: .leading).shadow(radius: 10)
                                    Rectangle().cornerRadius(10).frame(width: waterStainBar, height: 30).foregroundColor(.colorWaterBar).frame(maxWidth: .infinity, alignment: .leading).shadow(radius: 10)
                                }
                                Text("Water Amount: \(plant.WaterAmount,specifier: "%.1f")mm").font(.title2.bold()).foregroundStyle(.fore1)
                                
                                //                            Text("Other:")
                                //
                                //                            ZStack{
                                //                                Rectangle().cornerRadius(10).frame(width: 200, height: 35).foregroundColor(.fore1.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading).shadow(radius: 10)
                                //                                Rectangle().cornerRadius(10).frame(width: 15, height: 30).foregroundColor(.fore1).frame(maxWidth: .infinity, alignment: .leading).shadow(radius: 10)
                                //                            }
                                
                            }.padding(10).frame(maxWidth: .infinity, alignment: .leading)
                            Rectangle().frame(width: .infinity, height: 30).foregroundColor(.colorDirtList)
                            
                        }
                        .frame(maxWidth: .infinity)      // optional: card width
                        .background(.colorBackgroundList)
                        .cornerRadius(12)
                        .shadow(radius: 4).padding(.horizontal)
                    }
                    
                }
            }.frame(maxWidth: .infinity).background(.back1)
            
        }.frame(maxWidth: .infinity).background(.back1)
    }
}
//#Preview {
//    let user = User()
//    user.person.garden = "TestGarden"
//    @StateObject var garden: Garden = Garden(user: user)
//    return ListView().environmentObject(garden)
//    
//}
