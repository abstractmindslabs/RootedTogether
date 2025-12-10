//
//  RootedTogetherApp.swift
//  RootedTogether
//
//  Created by Wells Wait on 10/30/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore




//Start FireBase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    //FirebaseApp.configure() - moved into user this was too slow

    return true
  }
}

// start firestore
let db = Firestore.firestore()


//Start The app
@main
struct RootedTogetherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var garden: Garden//we want just one instance of user
    @StateObject private var user: User
    
    @State private var BootUp: Bool = true
    init(){
        FirebaseApp.configure()
        let sharedUser = User()
        _user = StateObject(wrappedValue: sharedUser)
        _garden = StateObject(wrappedValue: Garden(user: sharedUser))
    }
    var body: some Scene {
        WindowGroup {
            ZStack{
                if BootUp{
                    Color(red: 248/255, green: 217/255, blue: 177/255) // Dodger Blue
                            .ignoresSafeArea()
                    
                        Image("bootUp")
                   
                    
                }else{
                    ContentView().environmentObject(garden).environmentObject(user)
                }
            }.onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    BootUp = false
                                }
            }
            
        }
    }
}
