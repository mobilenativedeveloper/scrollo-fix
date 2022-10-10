//
//  ChatListView.swift
//  scrollo
//
//  Created by Artem Strelnik on 14.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatListView: View {
    @Binding var offset: CGFloat
    @StateObject var chatViewModel : ChatViewModel = ChatViewModel()
    @State private var searchText : String = String()
    @State var isShowing: Bool = false
    
    @State var refreshing: Bool = false
    
    @State var presentNewChat: Bool = false
    @State var pushOnNewChat: Bool = false
    @State var receiver: ChatListModel.ChatModel.ChatUser = ChatListModel.ChatModel.ChatUser(id: "", login: "", name: nil, avatar: nil)
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0) {
                HeaderBar(offset: $offset, presentNewChat: $presentNewChat)
                VStack {
                    HStack(spacing: 0) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(Color.gray)
                            .padding(.trailing, 13)
                        TextField("Найти чат", text: self.$searchText)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color(hex: "#ececec").opacity(0.5), radius: 30, x: 0, y: 0)
                    .padding(.horizontal)
                    .padding(.top, 15) //<--This mark
                    .padding(.bottom, 15) //<--This mark
                    
                    // Chat list
                    VStack(alignment: .leading, spacing: 13) {
                        if (chatViewModel.loadChats) {
                            if chatViewModel.chats.count > 0 || chatViewModel.favoriteChats.count > 0{
                                // Favorites chats
                                if chatViewModel.favoriteChats.count > 0{
                                    Text("Избранные контакты")
                                        .font(.custom(GothamMedium, size: 16))
                                        .foregroundColor(Color(hex: "#4F4F4F"))
                                        .padding(.bottom, 9) //<--This mark
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(0..<chatViewModel.favoriteChats.count, id: \.self) {index in
                                                FavoriteContactView(chat: chatViewModel.favoriteChats[index])
                                                    .environmentObject(chatViewModel)
                                            }
                                        }
                                    }
                                    .padding(.bottom, 5) //<--This mark
                                }
                                ForEach(0..<chatViewModel.chats.count, id: \.self) {index in
                                    ChatItemView(chat: $chatViewModel.chats[index], chatList: $chatViewModel.chats)
                                        .environmentObject(chatViewModel)
                                }
                            }
                            else{
                                VStack(alignment: .center){
                                    Text("Напишите свои друзьям")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#333333"))
                                        .padding(.bottom, 5)
                                    Text("Обменивайтесь сообщениями, или делитесь своими любимыми публикациями прямо с людьми, которые вам важны.")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .frame(width: UIScreen.main.bounds.width - 80)
                                }
                                .padding(.top, 50)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal)
                }
                .pullToRefresh(refreshing: $refreshing, backgroundColor: Color(hex: "#F9F9F9")) { done in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        chatViewModel.getChats {
                            done()
                        }
                        
                    }
                }
            }
            .background(
                NavigationLink(destination: ChatMessagesView(user: receiver).ignoreDefaultHeaderBar, isActive: $pushOnNewChat, label: {
                    EmptyView()
                })
            )
            .background(Color(hex: "#F9F9F9").edgesIgnoringSafeArea(.all))
            .ignoreDefaultHeaderBar
            .navigationView(isPresent: $presentNewChat, content: {
                CreateNewChatView(presentNewChat: $presentNewChat) { newChat in
                    chatViewModel.chats.append(newChat)
                    withAnimation{
                        presentNewChat.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        receiver = newChat.receiver
                        pushOnNewChat.toggle()
                    }
                }
            })
            .onAppear {
                
                chatViewModel.getChats{
                    
                }
            }
        }
        
    }
}

private struct HeaderBar: View {
    @Binding var offset: CGFloat
    @Binding var presentNewChat: Bool
    var body: some View{
        HStack {
            Button(action: {
                offset = 0
            }) {
                Image("circle.left.arrow.black")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
            Spacer(minLength: 0)
            VStack(spacing: 4) {
                Text("lana_smith")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#828796"))
                Text("Сообщения")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#2E313C"))
            }
            Spacer(minLength: 0)
            Button(action: {
                withAnimation{
                    presentNewChat.toggle()
                }
            }) {
                Image("new.message")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
