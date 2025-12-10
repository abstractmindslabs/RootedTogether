//
//  PlantTypeInfoView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/13/25.
//

import SwiftUI

struct PlantTypeInfoView: View {
    @State var plantType: PlantType
    @StateObject var plantOptions: PlantOptions
    @EnvironmentObject var user: User
    var body: some View {
        NavigationStack{
            VStack
            {
                ZStack{
                    ScrollView{
                        HStack{
                            Text(plantType.name)
                                .font(.largeTitle)
                                .bold().padding(10)
                            Image(PlantIcons[plantType.plantIcon]).resizable().aspectRatio(contentMode: .fit).frame(width:70, height:70)
                        }
                        
                        
                        Text("Scientific Name: \(plantType.sciName)").font(.title2).padding(10)
                        Text("Descrition: \(plantType.plantDescription)")
                            .font(.title2).padding(10)
                        Text("Planting: \(plantType.planting)")
                            .font(.title2).padding(10)
                        Text("Harvest: \(plantType.harvest)")
                            .font(.title2).padding(10)
                        Text("Water Needs: \(plantType.waterNeeds)")
                            .font(.title2).padding(10)
                        Text("Light Needs: \(plantType.lightNeeds)")
                            .font(.title2).padding(10)
                        Text("problems: \(plantType.problems)")
                            .font(.title2).padding(10)
                    }
                    VStack{
                        Spacer()
                        NavigationLink{
                            PlacePlantView(plantOptions: plantOptions, plantType: plantType, bed: false)
                        }label:{
                            Text("Add To Garden").font(.title).padding(10).background(.back2).cornerRadius(10).padding(5)
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.back1)
        }
    }
}

#Preview {
    let user = User()
    let plantType = PlantType(name: "name", plantDescription: "plantDescription", sciName: "sciName", harvest: "harvest", lightNeeds: "lightNeeds", planting: "planting", problems: "problems", waterNeeds: "waterNeeds", CropCoefficient: Double(1), WaterAmount: Double(1), CumulativeDepletion: Double(1), FieldCapacity: Double(1), WiltingPoint: Double(1), p: Double(1), RootDepth: Double(1), plantIcon: 0)
    let garden: Garden = Garden(user: user)
    let plantOptions: PlantOptions = PlantOptions(user: user)
    PlantTypeInfoView(plantType: plantType, plantOptions: plantOptions).environmentObject(garden).environmentObject(user)
}
