//
//  MapView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct PlacePlantView: View {
    @EnvironmentObject private var garden: Garden
    
    @StateObject var plantOptions: PlantOptions
    @State var plantType: PlantType
    
    let bed: Bool
    @State private var width: CGFloat = 100
    @State private var height: CGFloat = 100
    
    
    //move varibles
    @State private var scale: CGFloat = 1
    @State private var LastScale: CGFloat = 1
    
    @State private var offset: CGSize = .zero
    @State private var LastOffset: CGSize = .zero
    
    
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    //diffrent data display options
    enum Mode: String, CaseIterable{
        case health, water, nitorgen , growth
    }
    @State private var mode: Mode = .health
    
    
    
    //@State private var
    var body: some View {
        NavigationStack{
            
            ZStack{
            GeometryReader { geometry in
                ZStack{
                    
                    //background
                    Rectangle().fill(.back1).position(x:0, y:0).frame(width: 2000, height: 2000)
                    //boarder
                    Rectangle().stroke(style: StrokeStyle(lineWidth: 10)).position(x:0, y:0).frame(width: 2000, height: 2000).foregroundColor(.black)
                    
                    //place beds
                    ForEach(garden.beds, id: \.id){bed in
                        Rectangle().fill(.fore2).frame(width: CGFloat(bed.lx), height: CGFloat(bed.ly)).position(bed.position)
                        
                    }
                    // place bed marker
                    if bed {
                        ZStack{
                            Rectangle().frame(width: CGFloat(width), height: CGFloat(height)).foregroundColor(.green)
                        }.position(x: (screenWidth/2)*(2*scale-1) - offset.width*(1/scale), y:(-150 + screenHeight/2)*(2*scale-1) - offset.height*(1/scale))
                        
                    }
                    //plants
                    ForEach(Array(garden.plants.enumerated()), id: \.element.id){index, plant in
                        //plant individual
                        
                        ZStack{
                            Circle().stroke(style: StrokeStyle(lineWidth: 25)).frame(width: 100, height: 100).foregroundColor(.fore1)
                            Text(plant.name).foregroundColor(.fore1)
                            }.position(plant.position)
    
                    }
                    //place plant marker
                    
                    if !bed{
                        Circle().frame(width: 100, height: 100).position(x: (screenWidth/2)*(2*scale-1) - offset.width*(1/scale), y:(-150 + screenHeight/2)*(2*scale-1) - offset.height*(1/scale)).foregroundColor(.green)
                        Circle().stroke(style: StrokeStyle(lineWidth: 25)).frame(width: 100, height: 100).position(x: (screenWidth/2)*(2*scale-1) - offset.width*(1/scale), y:(-150 + screenHeight/2)*(2*scale-1) - offset.height*(1/scale)).foregroundColor(.black)
                    }
                    
                    
                    
                    
                    //handles map like effects
                    
                }.scaleEffect(scale).offset(x: offset.width, y: offset.height).gesture(SimultaneousGesture(
                    DragGesture().onChanged{value in
                        offset = CGSize(
                            width: LastOffset.width + value.translation.width,
                            height: LastOffset.height + value.translation.height)
                    }.onEnded{ _ in LastOffset = offset },
                    MagnificationGesture().onChanged{ value in
                        scale = min(max(LastScale+(value-1)/3,0.9),1.1)
                        
                        
                        //
                        //
                        //offset.width = LastOffset.width * (scale/LastScale)
                        //offset.height = LastOffset.height + LastOffset.height * (scale - LastScale)
                        
                    }.onEnded{_ in LastScale = scale
                        LastOffset = offset}
                    
                ))
                
                
                
                
                //out of bounds back gorund is white
            }.background(.white)
                
                VStack{
                    Text("Scroll around to place plant.").padding(60).ignoresSafeArea()
                    Spacer()
                    
                    Button(bed ? "Submit Bed" : "Submit Plant"){
                        var a: Float = Float((screenWidth/2)*(2*scale-1))
                        var b: Float = Float(offset.width*(1/scale))
                        let x: Float = a - b
                        a = Float((-150+screenHeight/2)*(2*scale-1))
                        b = Float(offset.height*(1/scale))
                        let y: Float = a - b
                        Task{
                            
                            //await plantOptions.addPlantToGarden(plantType: plantType, x: (-1000+screenWidth/2+25)*(1/scale) - offset.width*(1/scale), y: (screenHeight/2+150)*(scale/2)-offset.height*(1/scale))
                            if bed{
                                await plantOptions.addBedToGarden(x: x, y: y, lx: Float(width), ly: Float(height))
                            }else{
                                await plantOptions.addPlantToGarden(plantType: plantType, x: x, y: y)
                            }
                        }
                        
                    }.font(.title2).padding(9).background(.back2).cornerRadius(10).padding(1).foregroundColor(.fore1)
                    if bed{
                        VStack{
                            Text("Width:")
                            Slider(value: $width, in: 100...500.0, step: 0.1).padding(.horizontal)
                        }.padding(1)
                        VStack{
                            Text("Height:")
                            Slider(value: $height, in: 100...500.0, step: 0.1).padding(.horizontal)
                        }.padding(1)
                            
                        
                    }
                }
        }
        }.onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                self.screenWidth = windowScene.screen.bounds.width
                self.screenHeight = windowScene.screen.bounds.height
                
            }}
    }
    

}

#Preview {
    let user: User = User()
    //user.person.id = "OxDcgxJwh3TLcC8kZPI8AhwRXbH2"
    let garden: Garden = Garden(user: user)

    let plantType = PlantType(name: "name", plantDescription: "plantDescription", sciName: "sciName", harvest: "harvest", lightNeeds: "lightNeeds", planting: "planting", problems: "problems", waterNeeds: "waterNeeds", CropCoefficient: Double(1), WaterAmount: Double(1), CumulativeDepletion: Double(1), FieldCapacity: Double(1), WiltingPoint: Double(1), p: Double(1), RootDepth: Double(1), plantIcon: 0)

    let plantOptions: PlantOptions = PlantOptions(user: user)
    
    PlacePlantView(plantOptions: plantOptions, plantType: plantType, bed: true).environmentObject(garden)
}

