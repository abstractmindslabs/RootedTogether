//
//  ChatView.swift
//  RootedTogether
//
//  Created by Wells Wait on 11/1/25.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var user: User
    @StateObject private var chat: Chat
    @State private var screenWidth: CGFloat = 0
    
    @State var message: String = ""
    init(user: User){
        _chat = StateObject(wrappedValue: Chat(user: user))
    }

    var body: some View {
        VStack{
            ScrollViewReader { proxy in
                ScrollView {
                    if !chat.messages.isEmpty{
                        
                        LazyVStack{
                            ForEach(chat.messages, id: \.id){message in
                                
                                ChatBuble(message: message.message,
                                          name: message.name,
                                          width: screenWidth,
                                          
                                          userMessage: message.senderId == user.person.id).id(message.id)
                                
                                
                                
                                
                            }.frame(maxWidth: screenWidth)
                        }
                        
                        
                        
                    } else{
                        VStack{
                            Text("No Messages")
                        }
                    }
                    
                    
                }.onAppear(perform: {
                    self.scrollToBottom(proxy: proxy)
                })
            }
            HStack{
                TextField("Message", text: $message).padding(10).glassEffect().frame(maxWidth: screenWidth*6/8)
                Button("", systemImage: (message == "") ?  "xmark.circle.fill" : "arrow.up.circle.fill"){
                    
                    if message != ""{
                        Task {
                            await chat.sendMessage(message: message)
                            message = ""
                        }
                    }
                    hideKeyboard()
                    
                }.font(Font.largeTitle.bold())
            }.padding(10)
        }.onTapGesture {
            hideKeyboard()
        }.frame(maxWidth: screenWidth).background(.back1).onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                self.screenWidth = windowScene.screen.bounds.width
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastID = chat.messages.last?.id {
            withAnimation {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
}


struct ChatBuble: View{
    var message: String
    var name: String
    var width: CGFloat
    var userMessage: Bool
    var body: some View{
        VStack{

            Text("\(message)").padding(10).foregroundColor(userMessage ? .fore2 : .fore1).background(userMessage ? .colorUser : .colorCommunity).cornerRadius(20).frame(maxWidth: width/2, alignment: userMessage ? .trailing : .leading).padding(.horizontal, 10).shadow(radius: 6).fixedSize(horizontal: false, vertical: true)
            Text(name).foregroundColor(.black).frame(maxWidth: width/2, alignment: userMessage ? .trailing : .leading).padding(.bottom, 10)
         
            
            
        }.frame(maxWidth: width, alignment: userMessage ? .trailing : .leading)
    }
}
    

#Preview {

    let sampleUser = User()
    sampleUser.person.id = "OxDcgxJwh3TLcC8kZPI8AhwRXbH2"
    return ChatView(user: sampleUser)
        .environmentObject(sampleUser)
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
