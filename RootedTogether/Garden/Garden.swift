import Foundation
import Combine
import FirebaseFirestore
import WeatherKit
import CoreLocation

class Garden: ObservableObject {
    @Published var gardenName: String
    @Published var gardenCode: String
    @Published var editCode: String
    
    private var latitude: Double
    private var longitude: Double
    private var user: User
    private var cancellables = Set<AnyCancellable>()
    
    @Published var plants: [Plant] = []
    @Published var beds: [Bed] = []
    init(user: User){
        self.user=user
        gardenName = ""
        editCode = ""
        gardenCode = " "
        latitude = 0
        longitude = 0
        
        user.$person
            .sink { [weak self] newPerson in
                guard let self = self else { return }
                // Only refresh if the user has a valid garden code
                if !newPerson.garden.isEmpty {
                    self.gardenCode = newPerson.garden
                    self.getGardenData()
                }
            }
            .store(in: &cancellables)
        
        if user.SignedInUser {
            gardenCode = user.person.garden
            //fake set
            if gardenCode == "" {
                //prevent error
                gardenCode = " "
            }
            
            //update set
            getGardenData()
        } else {
            editCode = " "
        }
    }
    func getGardenData(){
        
        db.collection("Garden").document(gardenCode).getDocument{ (document, error) in
            if let document = document, document.exists {
                DispatchQueue.main.async {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    self.gardenName = document.get("gardenName") as? String ?? ""
                    self.editCode = document.get("editCode") as? String ?? ""
                    self.latitude = document.get("latitude") as? Double ?? 30
                    self.longitude = document.get("longitude") as? Double ?? -100
                    
                }
                
                
                
            } else {
                self.gardenName="No Garden"/*do nothing they don't exsist*/}}
        if self.gardenCode.count > 4 {
            self.getPlants()
            self.getBeds()
            
        }
        
    }
    func makeGarden(gardenName: String, gardenCode: String, editCode: String, latitude: Double, longitude: Double) async{
        
        do {
            //update firebase data
            try await db.collection("Garden").document(gardenCode).setData( [
                "gardenName": gardenName,
                "gardenCode": gardenCode,
                "editCode": editCode
                ,"latitude": latitude
                ,"longitude": longitude
            ])
            //update runtime data
            self.gardenName = gardenName
            self.gardenCode = gardenCode
            self.editCode = editCode
            
            //get plants
            
        } catch {
            //print("Error adding document: \(error)")
        }
    }
    func getPlants() {
        
        db.collection("Garden").document(self.gardenCode).collection("Garden").order(by: "WaterStrain").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            self.plants = documents.map { (queryDocumentSnapshot) -> Plant in
                let data = queryDocumentSnapshot.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let name = data["name"] as? String ?? "No Name"
                let px = (data["px"] as? Double).map { Int($0) } ?? 0
                let py = (data["py"] as? Double).map { Int($0) } ?? 0
                let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                let waterStrain: Double = data["WaterStrain"] as? Double ?? 1
                let waterAmount: Double = data["WaterAmount"] as? Double ?? 10
                let cumulativeDepletion: Double = data["CumulativeDepletion"] as? Double ?? 0
                let p: Double = data["p"] as? Double ?? 0.3
                let rootDepth: Double = data["RootDepth"] as? Double ?? 0.5
                let cropCoefficient: Double = data["CropCoefficient"] as? Double ?? 0.3
                let fieldCapacity: Double = data["FieldCapacity"] as? Double ?? 0.9
                let wiltingPoint: Double = data["WiltingPoint"] as? Double ?? 0.3
                let plantIcon: Int = data["plantIcon"] as? Int ?? 0

                return Plant(
                    id: id,
                    name: name,
                    position: CGPoint(x: px, y: py),
                    CropCoefficient: cropCoefficient,
                    date: date,
                    WaterStrain: waterStrain,
                    WaterAmount: waterAmount,
                    CumulativeDepletion: cumulativeDepletion,
                    FieldCapacity: fieldCapacity,
                    WiltingPoint: wiltingPoint,
                    p: p,
                    RootDepth: rootDepth,
                    plantIcon: plantIcon
                )

            }
        }
    }
    func updatePlant(id: String,
     date: Date,
     WaterStrain: Double,
     WaterAmount: Double,
     CumulativeDepletion: Double,
     p: Double,
     RootDepth: Double) async{
         
        
        do {
            //update firebase data
            try await db.collection("Garden").document(self.user.person.garden).collection("Garden").document(id).updateData( [
    
                "date": date,
                "WaterStrain": WaterStrain,
                "WaterAmount": WaterAmount,
                "CumulativeDepletion": CumulativeDepletion,
                "p": p,
                "RootDepth": RootDepth

          ])

          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
    func getBeds() {
        
        db.collection("Garden").document(self.gardenCode).collection("GardenBed").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            self.beds = documents.map { (queryDocumentSnapshot) -> Bed in
                let data = queryDocumentSnapshot.data()
                let id = data["id"] as? String ?? UUID().uuidString
                
                let px = (data["px"] as? Double).map { Int($0) } ?? 0
                let py = (data["py"] as? Double).map { Int($0) } ?? 0
                let lx = (data["lx"] as? Double).map { Int($0) } ?? 0
                let ly = (data["ly"] as? Double).map { Int($0) } ?? 0
                return Bed(id: id, position: CGPoint(x: px, y: py), lx: lx, ly: ly)
            }
        }
    }
    func waterPlants(index: Int, amount: Double){
        //adjust plant threshold and send it
        self.plants[index].WaterAmount += amount
        self.plants[index].WaterStrain = 1
        self.plants[index].CumulativeDepletion = 0
        
        
        //add contribution
        Task{
            try await updatePlant(id: self.plants[index].id,
                        date: Date(),
                        WaterStrain: self.plants[index].WaterStrain,
                        WaterAmount: self.plants[index].WaterAmount,
                        CumulativeDepletion: self.plants[index].CumulativeDepletion,
                        p: self.plants[index].p,
                        RootDepth: self.plants[index].RootDepth)
            await user.addContribution()
        }
    }
    // Water simulation
    
    
    // MARK: - Look-up Data Tables (Annex II)
    
    // Annex II > Table 2.6 Daily Extraterrestrial Radiation (R_a)
    let raNorthernHemisphereData: [[Float]] = [
        [36.2, 37.5, 37.9, 36.8, 34.8, 33.4, 33.9, 35.7, 37.2, 37.4, 36.3, 35.6], // Lat 0
        [35.4, 37.0, 37.8, 37.1, 35.4, 34.2, 34.6, 36.1, 37.3, 37.0, 35.6, 34.8], // Lat 2
        [34.6, 36.4, 37.6, 37.4, 36.0, 35.0, 35.3, 36.5, 37.3, 36.6, 34.9, 33.9], // Lat 4
        [33.7, 35.8, 37.4, 37.6, 36.6, 35.7, 35.9, 36.9, 37.3, 36.1, 34.1, 32.9], // Lat 6
        [32.8, 35.2, 37.2, 37.7, 37.1, 36.3, 36.5, 37.2, 37.2, 35.6, 33.3, 32.0], // Lat 8
        [31.8, 34.5, 36.9, 37.9, 37.6, 37.0, 37.1, 37.5, 37.1, 35.1, 32.4, 31.0], // Lat 10
        [30.9, 33.8, 36.5, 38.0, 38.0, 37.6, 37.6, 37.8, 36.9, 34.5, 31.5, 30.0], // Lat 12
        [29.9, 33.1, 36.1, 38.1, 38.4, 38.1, 38.1, 38.0, 36.7, 33.9, 30.6, 28.9], // Lat 14
        [28.9, 32.3, 35.7, 38.1, 38.7, 38.6, 38.5, 38.1, 36.4, 33.2, 29.6, 27.9], // Lat 16
        [27.9, 31.5, 35.2, 38.0, 39.0, 39.1, 38.9, 38.2, 36.1, 32.5, 28.7, 26.8], // Lat 18
        [26.8, 30.6, 34.7, 37.9, 39.3, 39.5, 39.3, 38.3, 35.8, 31.8, 27.7, 25.6], // Lat 20
        [25.7, 29.7, 34.1, 37.8, 39.5, 40.0, 39.6, 38.4, 35.4, 31.0, 26.6, 24.5], // Lat 22
        [24.6, 28.8, 33.5, 37.6, 39.7, 40.3, 39.9, 38.3, 34.9, 30.2, 25.5, 23.3], // Lat 24
        [23.4, 27.8, 32.8, 37.4, 39.9, 40.6, 40.2, 38.3, 34.5, 29.3, 24.5, 22.2], // Lat 26
        [22.3, 26.8, 32.2, 37.1, 40.0, 40.9, 40.4, 38.2, 33.9, 28.5, 23.3, 21.0], // Lat 28
        [21.1, 25.8, 31.4, 36.8, 40.0, 41.2, 40.6, 38.1, 33.4, 27.6, 22.2, 19.8], // Lat 30
        [19.9, 24.8, 30.7, 36.5, 40.0, 41.4, 40.7, 37.9, 32.8, 26.6, 21.1, 18.5], // Lat 32
        [18.7, 23.7, 29.9, 36.1, 40.0, 41.6, 40.8, 37.6, 32.1, 25.6, 19.9, 17.3], // Lat 34
        [17.5, 22.6, 29.0, 35.7, 40.0, 41.7, 40.8, 37.4, 31.5, 24.6, 18.7, 16.1], // Lat 36
        [16.2, 21.5, 28.1, 35.2, 39.8, 41.8, 40.8, 37.0, 30.7, 23.6, 17.5, 14.8], // Lat 38
        [15.0, 20.4, 27.2, 34.7, 39.7, 41.9, 40.8, 36.7, 30.0, 22.5, 16.3, 13.6], // Lat 40
        [13.8, 19.2, 26.3, 34.1, 39.5, 41.9, 40.8, 36.3, 29.2, 21.4, 15.1, 12.4], // Lat 42
        [12.5, 18.0, 25.3, 33.5, 39.3, 41.9, 40.7, 35.9, 28.4, 20.3, 13.9, 11.1], // Lat 44
        [11.3, 16.9, 24.3, 32.9, 39.1, 41.9, 40.6, 35.4, 27.5, 19.2, 12.6, 9.9],  // Lat 46
        [10.1, 15.7, 23.3, 32.2, 38.8, 41.8, 40.4, 34.9, 26.6, 18.1, 11.4, 8.7],  // Lat 48
        [8.9, 14.4, 22.2, 31.5, 38.5, 41.7, 40.2, 34.4, 25.7, 16.9, 10.2, 7.5],  // Lat 50
        [7.7, 13.2, 21.1, 30.8, 38.2, 41.6, 40.1, 33.8, 24.7, 15.7, 9.0, 6.4],   // Lat 52
        [6.5, 12.0, 20.0, 30.0, 37.8, 41.5, 39.8, 33.2, 23.7, 14.5, 7.8, 5.2],   // Lat 54
        [5.4, 10.8, 18.9, 29.2, 37.4, 41.4, 39.6, 32.6, 22.7, 13.3, 6.7, 4.2],   // Lat 56
        [4.3, 9.6, 17.7, 28.4, 37.0, 41.3, 39.4, 32.0, 21.7, 12.1, 5.5, 3.1],   // Lat 58
        [3.3, 8.3, 16.6, 27.5, 36.5, 41.2, 39.2, 31.3, 20.6, 10.9, 4.4, 2.2],   // Lat 60
        [2.3, 7.1, 15.4, 26.6, 36.5, 41.2, 39.0, 30.6, 19.5, 9.7, 3.4, 1.3],   // Lat 62
        [1.4, 5.9, 14.1, 25.8, 35.8, 41.2, 38.8, 30.0, 18.4, 8.5, 2.4, 0.6],   // Lat 64
        [1.2, 0.8, 12.9, 24.8, 35.6, 41.4, 38.3, 29.3, 17.3, 7.2, 1.5, 0.1],   // Lat 66
        [0.6, 1.7, 11.2, 23.9, 35.5, 42.0, 38.9, 28.0, 16.1, 6.0, 0.7, 0.0],   // Lat 68
        [0.0, 2.6, 10.4, 23.0, 35.2, 42.4, 39.4, 28.6, 14.9, 4.9, 0.1, 0.0]    // Lat 70
    ]
    
    // Annex II > Table 2.7 Mean daylight hours (N)
    let nNorthernHemisphereData: [[Float]] = [// Lat 0
        [12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0],
        // Lat 2
        [11.9, 11.9, 12.0, 12.0, 12.1, 12.1, 12.1, 12.1, 12.0, 12.0, 11.9, 11.9],
        // Lat 4
        [11.8, 11.9, 12.0, 12.1, 12.2, 12.2, 12.2, 12.1, 12.0, 11.9, 11.8, 11.8],
        // Lat 6
        [11.7, 11.8, 12.0, 12.1, 12.3, 12.3, 12.3, 12.2, 12.0, 11.9, 11.7, 11.7],
        // Lat 8
        [11.6, 11.7, 11.9, 12.2, 12.4, 12.5, 12.4, 12.3, 12.0, 11.8, 11.6, 11.5],
        // Lat 10
        [11.5, 11.7, 11.9, 12.2, 12.5, 12.6, 12.5, 12.3, 12.1, 11.8, 11.5, 11.4],
        // Lat 12
        [11.4, 11.6, 11.9, 12.3, 12.6, 12.7, 12.6, 12.4, 12.1, 11.7, 11.4, 11.3],
        // Lat 14
        [11.3, 11.6, 11.9, 12.3, 12.6, 12.8, 12.8, 12.5, 12.1, 11.7, 11.3, 11.2],
        // Lat 16
        [11.1, 11.5, 11.9, 12.4, 12.7, 12.9, 12.9, 12.5, 12.1, 11.6, 11.2, 11.1],
        // Lat 18
        [11.0, 11.4, 11.9, 12.4, 12.8, 13.1, 13.0, 12.6, 12.1, 11.6, 11.1, 10.9],
        // Lat 20
        [10.9, 11.3, 11.9, 12.5, 12.9, 13.2, 13.1, 12.7, 12.1, 11.5, 11.0, 10.8],
        // Lat 22
        [10.8, 11.3, 11.9, 12.5, 13.1, 13.3, 13.2, 12.8, 12.1, 11.5, 10.9, 10.7],
        // Lat 24
        [10.7, 11.2, 11.8, 12.6, 13.2, 13.5, 13.3, 12.8, 12.1, 11.4, 10.8, 10.5],
        // Lat 26
        [10.5, 11.1, 11.8, 12.6, 13.3, 13.6, 13.5, 12.9, 12.1, 11.4, 10.7, 10.4],
        // Lat 28
        [10.4, 11.0, 11.8, 12.7, 13.4, 13.8, 13.6, 13.0, 12.2, 11.3, 10.6, 10.2],
        // Lat 30
        [10.3, 11.0, 11.8, 12.7, 13.5, 13.9, 13.8, 13.1, 12.2, 11.3, 10.5, 10.1],
        // Lat 32
        [10.1, 10.9, 11.8, 12.8, 13.6, 14.1, 13.9, 13.2, 12.2, 11.2, 10.3, 9.9],
        // Lat 34
        [10.0, 10.8, 11.8, 12.9, 13.8, 14.3, 14.1, 13.3, 12.2, 11.1, 10.2, 9.7],
        // Lat 36
        [9.8, 10.7, 11.7, 12.9, 13.9, 14.4, 14.2, 13.4, 12.2, 11.1, 10.1, 9.6],
        // Lat 38
        [9.6, 10.6, 11.7, 13.0, 14.1, 14.6, 14.4, 13.5, 12.2, 11.0, 9.9, 9.4],
        // Lat 40
        [9.5, 10.5, 11.7, 13.1, 14.2, 14.8, 14.6, 13.6, 12.2, 10.9, 9.7, 9.2],
        // Lat 42
        [9.3, 10.4, 11.7, 13.2, 14.4, 15.0, 14.8, 13.7, 12.3, 10.8, 9.6, 9.0],
        // Lat 44
        [9.1, 10.3, 11.6, 13.2, 14.6, 15.3, 15.0, 13.8, 12.3, 10.7, 9.4, 8.7],
        // Lat 46
        [8.8, 10.1, 11.6, 13.3, 14.8, 15.5, 15.2, 14.0, 12.3, 10.7, 9.2, 8.5],
        // Lat 48
        [8.6, 10.0, 11.6, 13.4, 15.0, 15.8, 15.5, 14.1, 12.3, 10.6, 9.0, 8.2],
        // Lat 50
        [8.3, 9.8, 11.6, 13.5, 15.2, 16.1, 15.7, 14.3, 12.3, 10.4, 8.7, 7.9],
        // Lat 52
        [8.0, 9.7, 11.5, 13.6, 15.4, 16.5, 16.0, 14.4, 12.4, 10.3, 8.5, 7.5],
        // Lat 54
        [7.7, 9.5, 11.5, 13.8, 15.7, 16.8, 16.4, 14.6, 12.4, 10.2, 8.2, 7.1],
        // Lat 56
        [7.3, 9.3, 11.5, 13.9, 16.0, 17.3, 16.8, 14.8, 12.4, 10.1, 7.9, 6.7],
        // Lat 58
        [6.9, 9.1, 11.4, 14.1, 16.4, 17.8, 17.2, 15.1, 12.5, 9.9, 7.5, 6.2],
        // Lat 60
        [6.4, 8.8, 11.4, 14.2, 16.8, 18.4, 17.7, 15.3, 12.5, 9.7, 7.1, 5.6],
        // Lat 62
        [5.7, 8.5, 11.3, 14.4, 17.3, 19.2, 18.4, 15.7, 12.6, 9.5, 6.6, 4.8],
        // Lat 64
        [5.0, 8.2, 11.2, 14.7, 17.9, 20.3, 19.2, 16.0, 12.6, 9.3, 6.0, 3.7],
        // Lat 66
        [3.9, 7.8, 11.2, 14.9, 18.7, 22.0, 20.3, 16.4, 12.7, 9.0, 5.2, 1.9],
        // Lat 68
        [2.1, 7.3, 11.1, 15.3, 19.7, 24.0, 22.3, 17.0, 12.7, 8.7, 4.1, 0.0],
        // Lat 70
        [0.0, 6.6, 11.0, 15.6, 21.3, 24.0, 24.0, 17.6, 12.8, 8.3, 2.3, 0.0]
    ]
    
    // Annex II > Table 2.2 Psychrometric constant (gamma)
    let altitudeToGamma: [Float: Float] = [
        0: 0.067, 100: 0.067, 200: 0.066, 300: 0.065, 400: 0.064, 500: 0.064,
        600: 0.063, 700: 0.062, 800: 0.061, 900: 0.061, 1000: 0.060,
        1100: 0.059, 1200: 0.058, 1300: 0.058, 1400: 0.057, 1500: 0.056,
        1600: 0.056, 1700: 0.055, 1800: 0.054, 1900: 0.054, 2000: 0.053,
        2100: 0.052, 2200: 0.052, 2300: 0.051, 2400: 0.051, 2500: 0.050,
        2600: 0.049, 2700: 0.049, 2800: 0.048, 2900: 0.047, 3000: 0.047,
        3100: 0.046, 3200: 0.046, 3300: 0.045, 3400: 0.045, 3500: 0.044,
        3600: 0.043, 3700: 0.043, 3800: 0.042, 3900: 0.042, 4000: 0.041
    ]
    
    // Annex II > Table 2.8 Stefan-Boltzmann Law
    let stefanBoltzmannData: [Float: Float] = [
        1.0: 27.7, 17.0: 34.75, 33.0: 43.08, 1.5: 27.9, 17.5: 34.99, 33.5: 43.36,
        2.0: 28.11, 18.0: 35.24, 34.0: 43.64, 2.5: 28.31, 18.5: 35.48, 34.5: 43.93,
        3.0: 28.52, 19.0: 35.72, 35.0: 44.21, 3.5: 28.72, 19.5: 35.97, 35.5: 44.5,
        4.0: 28.93, 20.0: 36.21, 36.0: 44.79, 4.5: 29.14, 20.5: 36.46, 36.5: 45.08,
        5.0: 29.35, 21.0: 36.71, 37.0: 45.37, 5.5: 29.56, 21.5: 36.96, 37.5: 45.67,
        6.0: 29.78, 22.0: 37.21, 38.0: 45.96, 6.5: 29.99, 22.5: 37.47, 38.5: 46.26,
        7.0: 30.21, 23.0: 37.72, 39.0: 46.56, 7.5: 30.42, 23.5: 37.98, 39.5: 46.85,
        8.0: 30.64, 24.0: 38.23, 40.0: 47.15, 8.5: 30.86, 24.5: 38.49, 40.5: 47.46,
        9.0: 31.08, 25.0: 38.75, 41.0: 47.76, 9.5: 31.3, 25.5: 39.01, 41.5: 48.06,
        10.0: 31.52, 26.0: 39.27, 42.0: 48.37, 10.5: 31.74, 26.5: 39.53, 42.5: 48.68,
        11.0: 31.97, 27.0: 39.8, 43.0: 48.99, 11.5: 32.19, 27.5: 40.06, 43.5: 49.3,
        12.0: 32.42, 28.0: 40.33, 44.0: 49.61, 12.5: 32.65, 28.5: 40.6, 44.5: 49.92,
        13.0: 32.88, 29.0: 40.87, 45.0: 50.24, 13.5: 33.11, 29.5: 41.14, 45.5: 50.56,
        14.0: 33.34, 30.0: 41.41, 46.0: 50.87, 14.5: 33.57, 30.5: 41.69, 46.5: 51.19,
        15.0: 33.81, 31.0: 41.96, 47.0: 51.51, 15.5: 34.04, 31.5: 42.24, 47.5: 51.84,
        16.0: 34.28, 32.0: 42.52, 48.0: 52.16, 16.5: 34.52, 32.5: 42.8, 48.5: 52.49
    ]
    
    // MARK: - Helper Functions
    
    /// Rounds a float value to the specified number of decimal places.
    func roundToPlaces(_ value: Float, places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (value * divisor).rounded() / divisor
    }
    
    /// Helper Method for extracting closest even latitude, default down if exactly odd.
    func mapLatToEvenLat(_ latitude: Float) -> Int {
        guard latitude >= 0 && latitude <= 70 else {
            fatalError("Latitude (degrees) must be between 0 and 70")
        }
        
        let latCeil = Int(ceil(latitude))
        let latFloor = Int(floor(latitude))
        
        if latCeil % 2 == 0 {
            return latCeil
        } else if latFloor % 2 == 0 {
            return latFloor
        } else {
            // Number is odd, take the lower even number (e.g., 41 -> 40)
            return latCeil - 1
        }
    }
    //
    ///// Maps latitude to the row index in the look-up tables (Lat 0 -> Index 0, Lat 2 -> Index 1, etc.).
    func mapLatToIndex(_ latitude: Float) -> Int {
        return mapLatToEvenLat(latitude) / 2
    }
    //
    ///// Returns: vapor pressure (kPa)
    ///// SOURCE: Annex 2 (Meteorological Tables) > Table 2.3
    func e(_ T: Float) -> Float {
        return 0.6108 * exp((17.27 * T) / (T + 237.3))
    }
    //
    ///// Returns: slope of the vapour pressure curve (kPa/°C)
    ///// SOURCE: Table 2.4 from Annex 2
    func Delta(_ T: Float) -> Float {
        let rawDelta = 4098.0 * (0.6108 * exp((17.27 * T) / (T + 237.3))) / pow(T + 237.3, 2)
        return roundToPlaces(rawDelta, places: 3)
    }
    //
    ///// Returns: psychrometric constant (kPa/°C) due to altitude differences in pressure
    ///// SOURCE: Table 2.2 from Annex 2
    func gamma(_ altitude: Float) -> Float {
        guard altitude >= 0 && altitude < 4500 else {
            fatalError("Altitude (m) must be between 0 and 4500")
        }
        let altitudeKey = roundToPlaces(round(altitude / 100) * 100, places: 0)
        guard let constant = altitudeToGamma[altitudeKey] else {
            // This should not happen if altitudeToGamma is complete
            fatalError("Gamma value not found for altitude: \(altitudeKey)")
        }
        return constant
    }
    //
    ///// Returns: closest key in stefanBoltzmannData to temperature T
    func mapTempToKey(_ T: Float) -> Float {
        let keys = Array(stefanBoltzmannData.keys)
        // Find the key that minimizes the absolute difference |T - key|
        if let closestKey = keys.min(by: { abs(T - $0) < abs(T - $1) }) {
            return closestKey
        }
        // Should not happen if data is present
        fatalError("Could not find closest temperature key.")
    }
    //
    //// MARK: - Main ET_0 Calculation Function
    //
    ///**
    // * Calculates the Grass Reference Evapotranspiration (ET_0) using the FAO Penman-Monteith method.
    // *
    // * @param T_max Daily maximum air temperature (°C).
    // * @param T_min Daily minimum air temperature (°C).
    // * @param altitude Altitude (m).
    // * @param u_2 Mean wind speed at 2m height (m/s).
    // * @param T_dew Dewpoint temperature (°C). Optional, used for `e_a` if provided.
    // * @param month Three-letter month abbreviation (e.g., "Jan").
    // * @param nHours Actual duration of sunshine (hours).
    // * @param latitude Latitude (degrees North, default 40). Must be [0, 70].
    // * @param RH_min Minimum relative humidity (0 to 100). Required if `T_dew` is nil.
    // * @param RH_max Maximum relative humidity (0 to 100). Required if `T_dew` is nil.
    // * @param R_s Measured shortwave radiation (MJ m^-2 d^-1). Optional.
    // * @param G_monthBool True to use monthly soil heat flux (G), false for daily (G=0).
    // * @param T_prior_month Mean temperature of the prior month (°C). Required if `G_monthBool` is true.
    // * @param T_current_month Mean temperature of the current month (°C). Required if `G_monthBool` is true.
    // * @param printState If true, prints intermediate calculation values.
    // * @returns ET_0 value (mm/day).
    // */
    func monthToIndex(_ month: String) -> Int {
        let validMonthStrings = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        guard let index = validMonthStrings.firstIndex(of: month) else {
            fatalError("Invalid month provided. Must be one of: \(validMonthStrings.joined(separator: ", "))")
        }
        return index
    }
        
        func ET_0(T_max: Float, T_min: Float, altitude: Float, u_2: Float,
                  T_dew: Float?, month: String, nHours: Float, latitude: Float = 40,
                  RH_min: Float? = nil, RH_max: Float? = nil, R_s: Float? = nil,
                  G_monthBool: Bool = false, T_prior_month: Float? = nil,
                  T_current_month: Float? = nil, printState: Bool = false) -> Float {
            
            // Check for latitude data availability
            guard latitude >= 0 && latitude <= 70 else {
                fatalError("Latitude must be between 0 and 70 for the built-in lookup tables.")
            }
            
            // Annex II > Table 2.6 Daily Extraterrestrial Radiation (R_a)
            let latIndex = mapLatToIndex(latitude)
            let monthIndex = monthToIndex(month)
            let R_a = raNorthernHemisphereData[latIndex][monthIndex]
            
            if printState {
                print("Ra from raNorthernHemisphereData: \(R_a)")
            }
            
            // BOX 11 CALCULATIONS: Basic Parameters
            let T_mean = roundToPlaces((T_max + T_min) / 2, places: 1)
            if printState {
                print("T_mean: \(T_mean)")
            }
            
            let deltaT_mean = Delta(T_mean)
            let gammaAlt = gamma(altitude)
            let c1 = roundToPlaces(1 + 0.34 * u_2, places: 2)
            if printState {
                print("c1: \(c1)")
            }
            let c2 = roundToPlaces(deltaT_mean / (deltaT_mean + gammaAlt * c1), places: 3)
            if printState {
                print("c2: \(c2)")
            }
            let c3 = roundToPlaces(gammaAlt / (deltaT_mean + gammaAlt * c1), places: 3)
            if printState {
                print("c3: \(c3)")
            }
            let c4 = roundToPlaces((900 / (T_mean + 273)) * u_2, places: 3)
            if printState {
                print("c4: \(c4)")
            }
            
            // Vapor pressure calculations
            let e_max = roundToPlaces(e(T_max), places: 3)
            let e_min = roundToPlaces(e(T_min), places: 3)
            
            // Saturation vapor pressure (e_s)
            let e_s = roundToPlaces((e_max + e_min) / 2, places: 3)
            if printState {
                print("\nSaturation vapor pressure calculation in Box 11:")
                print("e_s: \(e_s)")
            }
            
            // Actual vapor pressure (e_a)
            var e_a: Float = 0.0
            if let T_dew = T_dew {
                e_a = roundToPlaces(e(T_dew), places: 3) // e_a derived from dewpoint temperature
                if printState {
                    print("e_a (from T_dew): \(e_a)")
                }
            } else {
                guard let rhMin = RH_min, let rhMax = RH_max else {
                    fatalError("Either T_dew or RH_min and RH_max must be provided.")
                }
                guard 0 <= rhMin && rhMin <= 100 else {
                    fatalError("RH_min must be between 0 and 100")
                }
                guard 0 <= rhMax && rhMax <= 100 else {
                    fatalError("RH_max must be between 0 and 100")
                }
                
                if printState {
                    print("No dewpoint temperature provided, using relative humidity:")
                    print("RH_min: \(round(rhMin))")
                    print("RH_max: \(round(rhMax))")
                }
                
                let a = roundToPlaces((e_min * rhMax) / 100, places: 3)
                let b = roundToPlaces((e_max * rhMin) / 100, places: 3)
                e_a = roundToPlaces((a + b) / 2, places: 3)
                if printState {
                    print("e_a (from RH): \(e_a)")
                }
            }
            
            // Vapor Pressure Deficit
            let e_s_minus_e_a = roundToPlaces(e_s - e_a, places: 3)
            if printState {
                print("\nVapor Pressure Deficit:")
                print("e_s - e_a: \(e_s_minus_e_a)")
            }
            
            // Radiation Calculation Parameters:
            // Annex II > Table 2.7 Mean daylight hours (N)
            let N = nNorthernHemisphereData[latIndex][monthIndex]
            if printState {
                print("N: \(N)")
            }
            
            var final_R_s: Float
            if let R_s_measured = R_s {
                final_R_s = R_s_measured
                if printState {
                    print("R_s (measured): \(final_R_s)")
                }
            } else {
                // Approximating R_s IAW Box 11 [MJ m^-2 d^-1]
                final_R_s = roundToPlaces((0.25 + 0.5 * (nHours / N)) * R_a, places: 2)
                if printState {
                    print("R_s (approximated): \(final_R_s)")
                }
            }
            
            let R_so = roundToPlaces((0.75 + 2 * altitude / 100000) * R_a, places: 2) // [MJ m^-2 d^-1]
            if printState {
                print("R_so: \(R_so)")
            }
            
            // R_ns calculation
            let R_ns = roundToPlaces(0.77 * final_R_s, places: 2) // [MJ m^-2 d^-1]
            if printState {
                print("R_ns: \(R_ns)")
            }
            
            // Net Longwave Radiation (R_nl) parameters
            let b1 = roundToPlaces(final_R_s / R_so, places: 2) // Calculation in Box 11 > Radiation
            if printState {
                print("b1: \(b1)")
            }
            
            // Stefan-Boltzmann part
            let stefBoltzOutput_T_max = stefanBoltzmannData[mapTempToKey(T_max)]!
            let stefBoltzOutput_T_min = stefanBoltzmannData[mapTempToKey(T_min)]!
            let avg_stefBoltz_T = (stefBoltzOutput_T_max + stefBoltzOutput_T_min) / 2 // As in Box 11 Radiation
            if printState {
                print("avg_stefBoltz_T: \(avg_stefBoltz_T)")
            }
            
            let b2 = roundToPlaces(0.34 - 0.14 * sqrt(e_a), places: 2)
            if printState {
                print("b2: \(b2)")
            }
            let b3 = roundToPlaces(1.35 * b1 - 0.35, places: 2) // b1 is R_s/R_so
            if printState {
                print("b3: \(b3)")
            }
            
            // Net Longwave Radiation (R_nl)
            let R_nl = roundToPlaces(avg_stefBoltz_T * b2 * b3, places: 2)
            if printState {
                print("R_nl: \(R_nl)")
            }
            
            // Net Radiation (R_n)
            let R_n = roundToPlaces(R_ns - R_nl, places: 2)
            if printState {
                print("R_n: \(R_n)")
            }
            
            // Soil Heat Flux (G)
            var G: Float = 0.0
            if G_monthBool {
                guard let T_prior = T_prior_month, let T_current = T_current_month else {
                    fatalError("T_prior_month and T_current_month must be provided when G_monthBool is true.")
                }
                G = 0.14 * (T_current - T_prior) // G_month used
            }
            // Else G = 0.0 for daily calculation (G_day is assumed to be 0)
            if printState {
                print("G: \(G)")
            }
            
            // Grass reference evapotranspiration: (Box 11)
            let b4 = roundToPlaces(R_n - G, places: 2) // MJ m^-2 day^-1
            if printState {
                print("b4 (R_n - G): \(b4)")
            }
            let b5 = roundToPlaces(0.408 * b4, places: 2) // units [mm/day]
            if printState {
                print("b5 (0.408 * (R_n - G)): \(b5)")
            }
            
            // Penman-Monteith Final Calculation
            let grass1 = roundToPlaces(c2 * b5, places: 2)
            if printState {
                print("grass1 (Radiation term): \(grass1)")
            }
            let grass2 = roundToPlaces(c3 * c4 * e_s_minus_e_a, places: 2)
            if printState {
                print("grass2 (Aerodynamic term): \(grass2)")
                print("grass1 + grass2 (ET_0): \(grass1 + grass2)")
            }
            
            return (grass1 + grass2)
        }
    
        
        // MARK: - Utility Functions
        
        func convertKmPerHrToMPerSecond(_ speed: Float) -> Float {
            /**
             * Convert km/hr to m/s
             */
            return speed * 1000.0 / (60.0 * 60.0)
        }
        
        func convert10mWindSpeedHeightTo2Meters(_ speed: Float) -> Float {
            /**
             * Converts windspeed measured at a given height (over grass) to wind speed
             * measured at standard height of 2 m above ground surface (u_2).
             *
             * NOTE: The input `speed` in the original Python function comment is confusing,
             * as the constant values (67.8, 5.42) are for height (m), not speed (km/hr).
             * Assuming 'speed' here is the wind speed **measurement height (m)**
             * in line with FAO-56 Eq. 47/Table 2.9 (where z is the height in m).
             * I am keeping the original Python logic, which seems to treat the input
             * as the **measurement height** (e.g., 10m) if we look at the formula
             * in Table 2.9: $u_2 = u_z \frac{4.87}{\ln(67.8z - 5.42)}$. If the input 'speed'
             * is meant to be $z$, then the function signature is highly misleading.
             * I am implementing the Python formula exactly as written.
             */
            // Python: round(4.87/math.log(67.8*speed-5.42),3)
            let z = speed // Assuming 'speed' is actually the height z in meters for the constant
            let conversionFactor = roundToPlaces(4.87 / log(67.8 * z - 5.42), places: 3)
            return speed * conversionFactor
        }
    
    
    func RunSimulation() async throws{
        let service = WeatherService.shared
        
        var minDate = Date()
        //run through all plants and find min and max dates
        for plant in self.plants {
            if plant.date<minDate {
                minDate = plant.date
            }
        }
        // collect weather for all the plants
        var days = Calendar.current.dateComponents([.day], from: minDate, to: Date()).day ?? 0
        var result: [DayWeather] = []
        
        var startDate=minDate
        var endDate = Date()
        //anything with many days of no gardening
        while days > 7{
            endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? Date() //cap date
            var chunkResult = try await service.weather(
                for: CLLocation(latitude: self.latitude, longitude: self.longitude),
                including: .daily(startDate: startDate, endDate:  endDate)
            )
            startDate = endDate
            days -= 7
            print(days)
            
            result.append(contentsOf: chunkResult)
            
        }
        // handels the day ranges that are smaller than 7  ----- note does not include current day
        if Calendar.current.dateComponents([.day], from: minDate, to: Date()).day ?? 0 > 0{
            var chunkResult = try await service.weather(
                for: CLLocation(latitude: self.latitude, longitude: self.longitude),
                including: .daily(startDate: startDate, endDate: Date())
            )
            result.append(contentsOf: chunkResult)
        }
        
            
        
        
            
            
        // for loop of plants
        print("# of Plants: \(self.plants.count)")
        for plant_i in self.plants.indices{
            print("plant index \(plant_i)")
            print("plant id \(self.plants[plant_i].id)")
            var startIndex = Calendar.current.dateComponents([.day], from: minDate, to: plants[plant_i].date).day ?? 0
            print(result.count)
            print(startIndex)
            if startIndex < result.count{
                
                
                //for loop of days for that plant
                for day in result[startIndex...]{
                    // calqulate water loss rate -------------------------------------------------------------------------------
                    
                    
                    var hours: Float
                    if let sunrise = day.sun.sunrise,
                       let sunset = day.sun.sunset {
                        let interval = sunset.timeIntervalSince(sunrise)
                        hours = Float(interval / 3600.0)
                        
                    } else {
                        hours = 13
                    }
                    //find month
                    let formatter = DateFormatter()
                    formatter.dateFormat = "LLL" // "LLL" gives abbreviated month
                    let monthString = formatter.string(from: minDate)//assuming they don't leave plant for too long this should be close enough
                    
                    let et0Result = ET_0( T_max: Float(day.highTemperature.value), // °C
                                          T_min: Float(day.lowTemperature.value), // °C
                                          altitude: 1645, // m
                                          // The u_2 calculation, assuming 10 is the height (m) where wind speed was measured.
                                          u_2: convertKmPerHrToMPerSecond(convert10mWindSpeedHeightTo2Meters(Float(day.wind.speed.value))), T_dew: nil,
                                          month: monthString,
                                          nHours: hours, // hours
                                          latitude: Float(self.latitude), // °N
                                          RH_min: Float(day.minimumHumidity*100), // %
                                          RH_max: Float(day.maximumHumidity*100), // %
                                          // R_s is left as nil, triggering R_s approximation based on nHours and N.
                                          printState: false
                    )
                    var ET_C = plants[plant_i].CropCoefficient * self.plants[plant_i].WaterStrain * Double(et0Result)
                    
                    
                    
                    // calqulate current water amount
                    plants[plant_i].WaterAmount -= ET_C + day.precipitationAmountByType.rainfall.converted(to: .millimeters).value
                    // calqulate next day water strain----------------------------------------------------------------------
                    
                    //daily depletion fraction
                    let TAW = (plants[plant_i].FieldCapacity - plants[plant_i].WiltingPoint) * plants[plant_i].RootDepth * 1000 //mm
                    var RAW = TAW * plants[plant_i].p
                    let f_ET = ET_C / TAW
                    
                    
                    plants[plant_i].CumulativeDepletion = plants[plant_i].CumulativeDepletion + plants[plant_i].WaterStrain * f_ET
                    if plants[plant_i].CumulativeDepletion >= 1 {
                        plants[plant_i].WaterStrain = 0
                    }else if plants[plant_i].CumulativeDepletion <= plants[plant_i].p {
                        plants[plant_i].WaterStrain = 1//wrong
                    }else{
                        plants[plant_i].WaterStrain = (1-plants[plant_i].CumulativeDepletion)/(1-plants[plant_i].p)
                    }
                    
                    
                    
                }
                if Calendar.current.dateComponents([.day], from: plants[plant_i].date, to: Date()).day ?? 0 > 0{
                    await self.updatePlant(id: plants[plant_i].id, date: Date(), WaterStrain: plants[plant_i].WaterStrain, WaterAmount: plants[plant_i].WaterAmount, CumulativeDepletion: plants[plant_i].CumulativeDepletion, p: plants[plant_i].p, RootDepth: plants[plant_i].RootDepth)
                }
            }
            //update plant struct and firbase
            
            
            
        }
    
        
    }
    
        
        
    
}

