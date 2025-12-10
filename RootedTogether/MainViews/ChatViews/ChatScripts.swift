//
//  ChatScripts.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/9/25.
//
import SwiftUI
import Combine
import FirebaseFirestore

struct Message{
var id = UUID()
var message: String
var name: String
var senderId: String
var date: Date
    
}


class Chat: ObservableObject {
    private var user: User
    @Published var messages: [Message] = []
    init(user: User){
        self.user = user
        getMessages()
    }
    func getMessages() {

        
        db.collection("Garden").document(self.user.person.garden).collection("Messages").order(by: "date").limit(toLast: 25).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            self.messages = documents.map { (queryDocumentSnapshot) -> Message in
                let data = queryDocumentSnapshot.data()
                let message = data["message"] as? String ?? " "
                let name = data["name"] as? String ?? "Unknown"
                let senderId = data["senderId"] as? String ?? " "
                let date = data["date"] as? Date ?? Date()
     
                return Message(message: message, name: name, senderId: senderId, date: date)
            }
        }
        
    }
    func sendMessage(message: String) async{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let id = user.person.id + "-" + formatter.string(from: Date())
        
        do {
            //update firebase data
            try await db.collection("Garden").document(self.user.person.garden).collection("Messages").document(id).setData( [
                "name": user.person.name,
                "senderId": user.person.id,
            "message": message,
                "date": date,
                "id": id // not used for UUid just here in case of deltion action or something in future
          ])

          
        } catch {
          //print("Error adding document: \(error)")
        }
    }
    

}
