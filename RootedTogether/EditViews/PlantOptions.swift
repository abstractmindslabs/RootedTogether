//
//  PlantOptions.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/11/25.
//
import SwiftUI
import Combine
import Firebase
class PlantOptions: ObservableObject {
    @Published var plantTypes: [PlantType] = []
    private var user: User
    init(user: User) {
        self.user = user
        getPlantTypes()
    }
    func getPlantTypes(){
        
        
        
        db.collection("Garden").document(user.person.garden).collection("Plants").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            self.plantTypes = documents.map { (queryDocumentSnapshot) -> PlantType in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? "No Name"
                let plantDescription = data["description"] as? String ?? ""
                let sciName = data["scientific name"] as? String ?? ""
                let harvest = data["harvesting"] as? String ?? ""
                let lightNeeds = data["light needs"] as? String ?? ""
                let planting = data["planting"] as? String ?? ""
                let problems = data["problems"] as? String ?? ""
                let waterNeeds = data["water needs"] as? String ?? ""
                var CropCoefficient = data["CropCoefficient"] as? Double ?? 0.8
                var WaterAmount = data["WaterAmount"] as? Double ?? 20.0
                var CumulativeDepletion =  data["CumulativeDepletion"] as? Double ?? 0.0
                var FieldCapacity =  data["FieldCapacity"] as? Double ?? 0.9
                var WiltingPoint = data["WiltingPoint"] as? Double ?? 0.2
                var p = data["p"] as? Double ?? 0.5
                var RootDepth = data["RootDepth"] as? Double ?? 0.4
                var plantIcon = data["plantIcon"] as? Int ?? 0
                return PlantType(name: name, plantDescription: plantDescription, sciName: sciName, harvest: harvest, lightNeeds: lightNeeds, planting: planting, problems: problems, waterNeeds: waterNeeds, CropCoefficient: CropCoefficient, WaterAmount: WaterAmount, CumulativeDepletion: CumulativeDepletion, FieldCapacity: FieldCapacity, WiltingPoint: WiltingPoint, p: p, RootDepth: RootDepth, plantIcon: plantIcon)
            }
        }
        
        
        
        
        
    }
    func addPlantType(plantType: PlantType) async{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let id = plantType.name + "-" + formatter.string(from: Date())
        
        do {
            //update firebase data
            try await db.collection("Garden").document(self.user.person.garden).collection("Plants").document(id).setData( [
                "name": plantType.name,
                "description": plantType.plantDescription,
                "scientific name": plantType.sciName,
                "harvesting": plantType.harvest,
                "light needs": plantType.lightNeeds,
                "planting": plantType.planting,
                "problems": plantType.problems,
                "water needs": plantType.waterNeeds,
                "plantIcon": plantType.plantIcon,

                "id": id // not used for UUid just here in case of deltion action or something in future
          ])

          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
    func addPlantToGarden(plantType: PlantType, x: Float, y: Float) async{
         
         
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let id = plantType.name + "-" + formatter.string(from: Date())
        
        do {
            //update firebase data
            try await db.collection("Garden").document(self.user.person.garden).collection("Garden").document(id).setData( [
                "name": plantType.name,
                "px": Int(x.rounded()),
                "py": Int(y.rounded()),
                "id": id,
                "CropCoefficient": plantType.CropCoefficient,
                "date": Date(),
                "WaterStrain": 1,
                "WaterAmount": plantType.WaterAmount,
                "CumulativeDepletion": plantType.CumulativeDepletion,
                "FieldCapacity": plantType.FieldCapacity,
                "WiltingPoint": plantType.WiltingPoint,
                "p": plantType.p,
                "RootDepth": plantType.RootDepth,
                "plantIcon": plantType.plantIcon

          ])

          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
    func addBedToGarden(x: Float, y: Float, lx: Float, ly: Float) async{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let id = formatter.string(from: Date())
        
        do {
            //update firebase data
            try await db.collection("Garden").document(self.user.person.garden).collection("GardenBed").document(id).setData( [
                "px": Int(x.rounded()),
                "py": Int(y.rounded()),
                "lx": Int(lx.rounded()),
                "ly": Int(ly.rounded()),
                

                "id": id
          ])

          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
}
struct PlantType{
    var id = UUID()
    var name: String
    var plantDescription: String
    var sciName: String
    var harvest: String
    var lightNeeds: String
    var planting: String
    var problems: String
    var waterNeeds: String
    var CropCoefficient: Double
    var WaterAmount: Double
    var CumulativeDepletion: Double
    var FieldCapacity: Double
    var WiltingPoint: Double
    var p: Double
    var RootDepth: Double
    var plantIcon: Int
}

