//
//  GardenEdit.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/11/25.
//

import SwiftUI

struct GardenEdit: View {
    @EnvironmentObject var garden: Garden
    @EnvironmentObject var user: User
    @StateObject var plantOptions: PlantOptions
    init(user: User){
        _plantOptions = StateObject(wrappedValue: PlantOptions(user: user))
        
    }
    var body: some View {
        NavigationStack{
            ZStack{
                
                VStack{
                    Text("Plant Types:").font(Font.largeTitle.bold()).frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                    
                ScrollView{
                    Text("Select plant to see more info or add to your garden")
                    LazyVStack{
                        VStack{
                            NavigationLink(destination: PlacePlantView(plantOptions: plantOptions, plantType: PlantType(name: " ", plantDescription: " ", sciName: " ", harvest: " ", lightNeeds: " ", planting: " ", problems: "problems", waterNeeds: " ", CropCoefficient: Double(0), WaterAmount: Double(0), CumulativeDepletion: Double(0), FieldCapacity: Double(0), WiltingPoint: Double(0), p: Double(0), RootDepth: Double(0), plantIcon:0), bed: true)){
                                Text("Create Bed").frame(maxWidth: .infinity, alignment: .leading).font(.title)
                            }
                            
                        }.padding().frame(maxWidth: .infinity).background(.fore1).cornerRadius(10).shadow(radius: 10).padding(10).foregroundColor(.back1)
                        
                        ForEach(self.plantOptions.plantTypes, id: \.id){plantType in
                            VStack{
                                NavigationLink(destination: PlantTypeInfoView(plantType: plantType, plantOptions: plantOptions)){
                                    Text(plantType.name).frame(maxWidth: .infinity, alignment: .leading).font(.title)
                                }
                                
                            }.padding().frame(maxWidth: .infinity).background(.back2).cornerRadius(10).shadow(radius: 10).padding(10)
                            
                        }
                    }
                }
            }
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        NavigationLink(){
                            AddPlantTypeView(plantOptions: plantOptions)
                        }label: {
                            // The label is what the user sees and taps
                            Image(systemName: "plus.circle.fill")
                                .font(.custom("Avenir Next", size: 50))
                                .foregroundColor(.fore1)
                        }
                    }.padding(.horizontal, 25)
                }

                
                
                
                
            }.background(.back1)
        }
    }
}

#Preview {
    let sampleUser = User()
    sampleUser.person.id = "OxDcgxJwh3TLcC8kZPI8AhwRXbH2"
    let sampleGarden = Garden(user: sampleUser)
    
    
    return GardenEdit(user: sampleUser)
        .environmentObject(sampleUser).environmentObject(sampleGarden)
    
}
