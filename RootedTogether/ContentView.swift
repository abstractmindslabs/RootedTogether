//
//  ContentView.swift
//  RootedTogether
//
//  Created by Wells Wait on 10/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var user: User
    @State var selected: Int?=nil
    @State var showInfo: Bool = false
    @State var SelectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $SelectedTab){
            HomeView().tabItem{Label("Home", systemImage: "house")}.tag(0)
            MapView(selected: $selected, showInfo: $showInfo, SelectedTab: $SelectedTab).tabItem{Label("Map", systemImage: "map")}.tag(1)
            ListView(SelectedTab: $SelectedTab, selected: $selected, showInfo: $showInfo).tabItem{Label("List", systemImage: "list.clipboard")}.tag(2)
            ChatView(user: user).tabItem{Label("Chat", systemImage: "square.and.pencil")}.tag(3)
        }.fullScreenCover(isPresented: Binding(
            get: { !user.SignedInUser },
            set: { _ in }
        )) {
            SignInView()
        }
    }
        
}


#Preview {
    @StateObject var user: User = User()
    @StateObject var garden: Garden = Garden(user: user)
    ContentView().environmentObject(garden).environmentObject(user)
}
