//
//  MapView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject private var garden: Garden
    
    //move varibles
    @State private var scale: CGFloat = 1
    @State private var LastScale: CGFloat = 1
    
    @State private var offset: CGSize = .zero
    @State private var LastOffset: CGSize = .zero
    
    //plant selcetions
    @Binding var selected: Int?
    @Binding var showInfo: Bool
    
    @State var selctorLocation: CGPoint = CGPoint(x: 5000, y: 5000)
    
    @Binding var SelectedTab: Int
    
    
    
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    
    @State private var waterAmount: String = "250"
    //diffrent data display options
    enum Mode: String, CaseIterable{
        case health, waterAmount, waterStrain
    }
    @State private var mode: Mode = .health
    
    // fake
    
    
    
    
    //@State private var
    var body: some View {
        
        NavigationStack{
            
            GeometryReader { _ in
                ZStack{
                    
                    //background
                    Rectangle().fill(.mapBackgroundText).position(x:0, y:0).frame(width: 2000, height: 2000)
                    //boarder
                    Rectangle().stroke(style: StrokeStyle(lineWidth: 10)).position(x:0, y:0).frame(width: 2000, height: 2000).foregroundColor(.black)
                    
                    
                    ForEach(garden.beds, id: \.id){bed in
                        Rectangle().fill(.mapBed).frame(width: CGFloat(bed.lx), height: CGFloat(bed.ly)).position(bed.position)
                        
                    }
                    
                    Circle().frame(width:150,height:150).position(selctorLocation).foregroundColor(.white.opacity(0.2))
                    
                    //plants
                    ForEach(Array(garden.plants.enumerated()), id: \.element.id){index, plant in
                        //plant individual
                        
                        //get data
                        let meter: Double = {
                                switch mode {
                                case .health:
                                    return plant.WaterStrain * 0.75
                                case .waterAmount:
                                    return plant.WaterAmount/40
                                case .waterStrain:
                                    return plant.WaterStrain * 0.75
                                default:
                                    return plant.WaterStrain * 0.75
                                }
                            }()
                        
                        
                        
                        //show
                        

                        VStack{
                            
                            ZStack{
                                Circle().trim(from: 0, to: 0.75).stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 25, lineCap: .round)).rotationEffect(.degrees(-225)).frame(width:100,height:100)
                                Circle().trim(from: 0, to: meter).stroke(meter > 1/4 ? (meter > 2/4 ? .colorMeterGreen : .colorMeterYellow) : .colorMeterRed,
                                                                         style: StrokeStyle(lineWidth: 25, lineCap: .round)).rotationEffect(.degrees(-225)).frame(width:100,height:100).shadow(radius: 4)
                                Image(PlantIcons[plant.plantIcon]).resizable().aspectRatio(contentMode: .fit).frame(width:70, height:70)
                            }
                            Text(plant.name).foregroundColor(.mapBackgroundText)
                                
                        }.position(plant.position).onTapGesture {
                            selected = index
                            selctorLocation = garden.plants[selected ?? 0].position
                            showInfo.toggle()
                            
                            
                        }
                }

                        
                //handles map like effects
                    
                }.scaleEffect(scale).offset(x: offset.width, y: offset.height).gesture(SimultaneousGesture(
                    DragGesture(minimumDistance: 20).onChanged{value in
                        offset = CGSize(
                            width: LastOffset.width + value.translation.width,
                            height: LastOffset.height + value.translation.height)
                    }.onEnded{ _ in LastOffset = offset },
                    MagnificationGesture().onChanged{ value in
                        scale = min(max(LastScale+(value-1)/3,0.5),3)
              
//                        offset.width = LastOffset.width + LastOffset.width * (scale - LastScale)
//                        offset.height = LastOffset.height + LastOffset.height * (scale - LastScale)
                                 
                                    }.onEnded{_ in LastScale = scale}
                    
                ))
                
                
                
                
                //out of bounds back gorund is white
            }.background(.mapBackgroundText)
                .sheet(isPresented: $showInfo){
                    
                    // this is the easy plant information
                    VStack{
                        Text(garden.plants[selected ?? 0].name)
                        HStack{
                            Button("Water 20mm"){
                                garden.waterPlants(index: selected ?? 0, amount: 20)
                            }
                            Button("Water 1L"){
                                
                            }
                            HStack{
                                TextField("Amount", text: $waterAmount).keyboardType(.numberPad)
                                Button("Custom Water (ml)"){
                                    //convert water amount to int
                                }
                                
                            }.glassEffect()
                        }
                        
                        
                    }.presentationDetents([.fraction(0.5)]) // Half screen
                        .presentationDragIndicator(.visible)
                }
                .toolbar{//toolbar with options
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu("Options"){
                        //reset view
                        Button("Reset", systemImage: "house"){
                            scale = 1;
                            LastScale=1;offset = .zero;LastOffset = .zero
                        }
                        
                        Picker("Plant Metric", selection: $mode){
                            
                            ForEach(Mode.allCases,id:\.self){mode in
                                Text(mode.rawValue.capitalized).font(Font.largeTitle)
                            }
                            
                        }//.pickerStyle(SegmentedPickerStyle())
                        
                        
                    }
                }
            }
        }.onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                self.screenWidth = windowScene.screen.bounds.width
                self.screenHeight = windowScene.screen.bounds.height
                
            }
            if selected != nil{
                scale = 1
                LastScale = 1
                
                offset = .zero
                LastOffset = .zero
                
                selctorLocation = garden.plants[selected ?? 0].position
            }
            
        }
    }
    

}

#Preview {
    let user = User()
    user.person.garden = "TestGarden"
    @StateObject var garden: Garden = Garden(user: user)
    @State var selected: Int? =  nil
    @State var showInfo: Bool = false
    @State var SelectedTab: Int = 0
    
    return MapView(selected: $selected, showInfo: $showInfo, SelectedTab: $SelectedTab).environmentObject(garden)
}
