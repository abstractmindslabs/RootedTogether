//
//  UserScripts.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//


import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase


class User: ObservableObject {

    @Published var SignedInUser: Bool
    @Published var person: Person = Person(name: " ", garden: " ",id: " ", gardenCode: " ")
    @Published var contributions: [Contribution] = []
    @Published var PersonalContribution: Contribution = Contribution(id: " ", name: " ", count: 0)
    @Published var TopFive: Bool = false
    
    init(){

        if checkAuth(){
            SignedInUser=true
            //pull user data at app open if signed in
            getPersonData()
            
        }else
            {
            SignedInUser=false//defalt false
        }
    }
    //this section has function handeling user authentication and registration
    func signInUser(email: String, password: String) async {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                print("Signed in user: \(authResult.user.uid)")
                self.SignedInUser=true
            } catch {
                print("Error signing in: \(error.localizedDescription), \(email), \(password)")
            }
        }
    func signUpUser(email: String, password: String) async -> String {
        do {
            let _ = try await Auth.auth().createUser(withEmail: email, password: password)
            return "Success"
        } catch {
            return error.localizedDescription
        }
    }

        func signOutUser() {
            do {
                try Auth.auth().signOut()
                
                self.SignedInUser = false
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }
    //This section handels user data
    func setPersonData(name: String, garden: String, gardenCode: String) async{
        do {
            //update firebase data
            try await db.collection("users").document(Auth.auth().currentUser!.uid).setData( [
            "name": name,
            "garden": garden,
            "id": Auth.auth().currentUser!.uid,
            "gardenCode": gardenCode
          ])
            //update runtime data
            person.name=name
            person.garden=garden
            person.id=Auth.auth().currentUser!.uid
          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
    
    func getPersonData() {
        if Auth.auth().currentUser != nil {
            

            db.collection("users").document(Auth.auth().currentUser?.uid ?? " ").getDocument{ (document, error) in
                
                if let document = document, document.exists {
                    DispatchQueue.main.async {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        self.person.name = document.get("name") as? String ?? " "
                        self.person.id = document.get("id") as? String ?? " "
                        self.person.garden=document.get("garden") as? String ?? " "
                        self.person.gardenCode=document.get("gardenCode") as? String ?? " "
                        self.getContributions()
                    }
                    
                } else {/*do nothing they don't exsist*/}}
            
        }else{
            person.name=" "
            person.id=" "
            person.garden=" "
        }
        
    }
    
    func getContributions(){
        self.getPersonData()
        if self.person.id.count > 2{
            db.collection("Garden").document(self.person.garden).collection("Contributions").order(by: "count", descending: true).limit(to: 5).addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    return
                }
                
                self.contributions = documents.map { (queryDocumentSnapshot) -> Contribution in
                    let data = queryDocumentSnapshot.data()
                    let id = data["id"] as? String ?? "No id"
                    let name = data["name"] as? String ?? "no name"
                    let count = (data["count"] as? Double).map { Int($0) } ?? 0
                    if id == self.person.id{
                        self.TopFive = true
                    }
                    
                    return Contribution(id: id, name: name, count: count )
                }
            }
            db.collection("Garden").document(self.person.garden).collection("Contributions").document(self.person.id).getDocument{ (document, error) in
                
                if let document = document, document.exists {
                    DispatchQueue.main.async {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        let id = document.get("id") as? String ?? " "
                        let name = document.get("name") as? String ?? " "
                        let count = (document.get("count") as? Double).map { Int($0) } ?? 0
                        self.PersonalContribution = Contribution(id: id, name: name, count: count)
                        
                    }
                    
                } else {/*do nothing they don't exsist*/
                    self.PersonalContribution = Contribution(id: self.person.id, name: self.person.name, count: 0)
                    
                }}
            
        }
    }
    
    func addContribution() async{
        do {
            //update firebase data
            try await db.collection("Garden").document(self.person.garden).collection("Contributions").document(self.person.id).setData( [
                "id": self.person.id,
                "name": self.person.name,
                "count": self.PersonalContribution.count+1
  
          ])
            //update runtime data
            self.PersonalContribution.count += 1
          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
    
    
}



    
func checkAuth()->Bool {
    if Auth.auth().currentUser != nil{
        return true
    }else{
        return false
    }
}


struct Person{
    var name: String
    var garden: String
    var id: String
    var gardenCode: String
}

struct Contribution{
    let id: String
    var name: String
    var count: Int
}
