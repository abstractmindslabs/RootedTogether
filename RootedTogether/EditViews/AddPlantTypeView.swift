//
//  AddPlantTypeView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/13/25.
//

import SwiftUI

struct AddPlantTypeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var plantDescription: String = ""
    @State private var harvest: String = ""
    @State private var lightNeeds: String = ""
    @State private var planting: String = ""
    @State private var problems: String = ""
    @State private var waterNeeds: String = ""
    @State private var sciName: String = ""
    
    @State private var CropCoefficient: String = ""
    @State private var WaterAmount: String = ""

    @State private var FieldCapacity: String = ""
    @State private var WiltingPoint: String = ""
    @State private var p: String = ""
    @State private var RootDepth: String = ""
    
    @StateObject var plantOptions: PlantOptions
    
    @State private var error: String = ""
    
    
    @State private var plantIcon: Int = 0
    
    
  
    
    
    var body: some View {
        VStack
        {
            ZStack{
                ScrollView{
                    Text("Plant Type Build").font(.largeTitle).padding(15)
                    Text("Name:").font(.title2).padding(10)
                    TextEditor(text: $name).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Scientific Name:").font(.title2).padding(10)
                    TextEditor(text: $sciName).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Descrition:")
                        .font(.title2).padding(10)
                    TextEditor(text: $plantDescription).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Planting:")
                        .font(.title2).padding(10)
                    TextEditor(text: $planting).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Harvest:")
                        .font(.title2).padding(10)
                    TextEditor(text: $harvest).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Water Needs:")
                        .font(.title2).padding(10)
                    TextEditor(text: $waterNeeds).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Light Needs:")
                        .font(.title2).padding(10)
                    TextEditor(text: $lightNeeds).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("problems:")
                        .font(.title2).padding(10)
                    TextEditor(text: $problems).frame(minHeight: 100, maxHeight: .infinity)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Text("Crop Coefficient:")
                        .font(.title2).padding(10)
                    TextField("", text: $CropCoefficient).border(Color.gray, width: 1).padding().background()
                    Text("Starting Water Amount(mm):")
                        .font(.title2).padding(10)
                    TextField("", text: $WaterAmount).border(Color.gray, width: 1).padding().background()
                    
                    Text("FieldCapacity (how much water the ground can hold):")
                        .font(.title2).padding(10)
                    TextField("", text: $FieldCapacity).border(Color.gray, width: 1).padding().background()
                    Text("Wilting Point:")
                        .font(.title2).padding(10)
                    TextField("", text: $WiltingPoint).border(Color.gray, width: 1).padding().background()
                    Text("p also called MAD:")
                        .font(.title2).padding(10)
                    TextField("", text: $p).border(Color.gray, width: 1).padding().background()
                    Text("Plant Root Depth: m")
                        .font(.title2).padding(10)
                    TextField("", text: $RootDepth).border(Color.gray, width: 1).padding().background()
                    Text("Plant Icon: - scroll to select")
                        .font(.title2).padding(10)
                    Picker("Image Selector", selection: $plantIcon) {
                                        
                                        // 4. ForEach iterates by index
                                        ForEach(0..<PlantIcons.count, id: \.self) { index in
                                            // Use the index to get the corresponding image name
                                            
                                            // Set the image properties to ensure a fixed size for the slot
                                            ZStack{
                            
                                                if index != plantIcon{
                                                    Image(PlantIcons[index])
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                    // **FIXED SIZE:** Use a fixed frame for every item
                                                        .frame(width: 50, height: 50)
                                                    // **TAG:** Crucially, set the tag to the current index
                                                        .tag(index)
                                                }else{
                                                    Image(PlantIcons[index])
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                    // **FIXED SIZE:** Use a fixed frame for every item
                                                        .frame(width: 90, height: 90)
                                                    // **TAG:** Crucially, set the tag to the current index
                                                        .tag(index)
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                    }.font(.largeTitle.bold())
                                    // Sets the visual area for the wheel
                    .frame(width: 200, height: 300)
                                    .clipped()
                                    .pickerStyle(WheelPickerStyle())
                    Rectangle().frame(width: 100, height: 400).foregroundColor(.back1)
                    
                    
                    
                }
                VStack{
                    Spacer()
                    Button("save"){
                        if !name.isEmpty {
                            Task{
                                await plantOptions.addPlantType(plantType: PlantType(name: name,
                                plantDescription: plantDescription,
                                sciName: sciName,
                                harvest: harvest,
                                lightNeeds: lightNeeds,
                                planting: planting,
                                problems: problems,
                                waterNeeds: waterNeeds,
                                CropCoefficient: Double(CropCoefficient) ?? 0.3,
                                WaterAmount: Double(WaterAmount) ?? 10,
                                CumulativeDepletion: Double(0),
                                FieldCapacity: Double(FieldCapacity) ?? 0.9,
                                WiltingPoint: Double(WiltingPoint) ?? 0.3,
                                p: Double(p) ?? 0.3,
                                RootDepth: Double(RootDepth) ?? 0.5,
                                plantIcon: plantIcon)
                                )
 

                                dismiss()
                            }
                            
                        }else{
                            error = "Name Required"
                        }
                        
                    }.font(.title).padding(10).background(name.isEmpty ? Color.gray.opacity(0.5) : Color.back2).cornerRadius(5).padding(10)
                    if !error.isEmpty {
                        
                        Text(error).padding(10).foregroundColor(.red).glassEffect()
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.back1)
    }
}

#Preview {
    let sampleUser = User()
    sampleUser.person.id = "OxDcgxJwh3TLcC8kZPI8AhwRXbH2"
    
    return AddPlantTypeView(plantOptions: PlantOptions(user: sampleUser))
}
