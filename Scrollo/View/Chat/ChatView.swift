//
//  ChatView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 06.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatView: View {
    @StateObject var chatViewModel : ChatViewModel = ChatViewModel()
    @State private var searchText : String = String()
    @State private var refreshing: Bool = false
    @State var isShowing: Bool = false
    @State var presentNewChat: Bool = false
    @State var pushOnNewChat: Bool = false
    @Binding var offset: CGFloat
    var body: some View {
        VStack(spacing: 0){
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
                .padding(.top, 15)
                .padding(.bottom, 15)
                VStack(alignment: .leading, spacing: 13){
                    if (chatViewModel.loadChats) {
                        if chatViewModel.chats.count > 0 || chatViewModel.favoriteChats.count > 0{
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
                chatViewModel.getChats{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        done()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .background(Color(hex: "#F9F9F9").edgesIgnoringSafeArea(.all))
        .navigationView(isPresent: $presentNewChat, content: {
            CreateChat(presentNewChat: $presentNewChat, onCreated: { newChat in
                
            })
        })
        .onAppear {
            chatViewModel.getChats{}
        }
    }
}

private struct FavoriteContactView : View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    var chat: ChatListModel.ChatModel
    var body : some View {
        NavigationLink(destination: Text("ChatMessagesView").ignoreDefaultHeaderBar) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    if let avatar = chat.receiver.avatar {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .cornerRadius(16)
                            .padding(.bottom, 8)
                    } else {
                        DefaultAvatar(width: 56, height: 56, cornerRadius: 16)
                    }
                    
                    Circle()
                        .fill(Color(hex: "#38DA7C"))
                        .frame(width: 13, height: 13)
                        .offset(x: 2, y: -9)
                }
                
                Text(chat.receiver.login)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#4F4F4F"))
            }
            .padding(.all, 4)
            .contextMenu {
                Button(action: {
                    chatViewModel.deleteFavorite(chat: self.chat)
                }) {
                    HStack{
                        Image(systemName: "star.slash")
                            .font(.title3)
                            .foregroundColor(.white)
                        Text("Удалить из избранного")
                    }
                }
            }
        }
        .buttonStyle(FlatLinkStyle())
    }
}

private struct ChatItemView: View{
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State var offset: CGFloat = .zero
    @State var isSwiped: Bool = false
    @Binding var chat: ChatListModel.ChatModel
    @Binding var chatList: [ChatListModel.ChatModel]
    
    var body: some View {
        NavigationLink(destination: Text("ChatMessagesView").ignoreDefaultHeaderBar) {
            ZStack {
                LinearGradient(gradient: .init(colors: [Color(hex: "#f55442"), Color(hex: "#fa6c5c").opacity(0.5)]), startPoint: .trailing, endPoint: .leading)
                    .clipShape(CustomCorner(radius: 15, corners: [.topLeft, .bottomLeft]))
                    .frame(height: 70)
                
                HStack{
                    Spacer(minLength: 90)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            deleteItem()
                        }
                    }){
                        Image(systemName: "trash")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 90, height: 70)
                    }
                }
                .padding(.trailing, 90)
                HStack{
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)){
                            addFavoriteChat()
                        }
                    }){
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 90, height: 70)
                    }
                    .background(Color(hex: "#36DCD8"))
                }
                
                
                
                HStack(spacing: 0) {
                    ZStack(alignment: .bottomTrailing) {
                        if let avatar = chat.receiver.avatar {
                            WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                                .resizable()
                                .frame(width: 44, height: 44)
                                .cornerRadius(10)
                        } else {
                            DefaultAvatar(width: 44, height: 44, cornerRadius: 10)
                        }
                        Circle()
                            .fill(Color(hex: "#38DA7C"))
                            .frame(width: 9, height: 9)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 14, height: 14)
                            )
                            .offset(x: 2)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(chat.receiver.login)
                            .font(.custom(GothamBold, size: 14))
                            .foregroundColor(Color(hex: "#2E313C"))
                        Text("See you on the next meeting! 😂")
                            .font(.custom(GothamBook, size: 14))
                            .foregroundColor(Color(hex: "#2E313C"))
                    }
                    .padding(.leading, 20)
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .frame(height: 70)
                .background(Color.white.clipShape(CustomCorner(radius: 15, corners: [.topLeft, .bottomLeft])))
                .shadow(color: Color(hex: "#778EA5").opacity(0.13), radius: 10, x: 3, y: 5)
                .contentShape(Rectangle())
                .offset(x: offset)
                .gesture(DragGesture().onChanged(onChange(value:)).onEnded(onEnd(value:)))
            }
        }
        .buttonStyle(FlatLinkStyle())
        
    }
    
    func onChange(value: DragGesture.Value){
        if value.translation.width < 0 {
            if self.isSwiped {
                self.offset = value.translation.width - 180
            }
            else {
                self.offset = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value){
        withAnimation(.easeInOut(duration: 0.3)) {
            if value.translation.width < 0{
                if -value.translation.width > UIScreen.main.bounds.width / 2{
                    self.offset = -1000
                    deleteItem()
                }
                else if -self.offset > 50{
                    self.isSwiped = true
                    self.offset = -180
                }
                else {
                    self.isSwiped = false
                    self.offset = 0
                }
            }
            else {
                self.isSwiped = false
                self.offset = 0
            }
        }
    }
    
    func deleteItem() {
        chatViewModel.removeChat(chatId: self.chat.id)
        chatList.removeAll{(item) -> Bool in
            return self.chat.id == item.id
        }
    }
    
    func addFavoriteChat(){
        chatViewModel.addFavorite(chat: self.chat)
        self.isSwiped = false
        self.offset = 0
    }
}

private struct CreateChat: View{
    @ObservedObject var createChatViewModel : CreateChatViewModel = CreateChatViewModel()
    @Binding var presentNewChat: Bool
    var onCreated: (ChatListModel.ChatModel)->Void
    var body: some View{
        VStack {
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation{
                        presentNewChat = false
                    }
                }) {
                    Image("circle_close")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                Text("Новое сообщение")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#2E313C"))
                Spacer(minLength: 0)
                Button(action: {
                  
                }) {
                    Image("circle.right.arrow.blue")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
            }
            .padding(.horizontal, 23)
            .padding(.bottom)
            VStack(alignment: .leading){
                Text("Кому: ")
                    .font(.custom(GothamBold, size: 14))
                    .foregroundColor(Color(hex: "#2E313C"))
                TextField("Поиск", text: $createChatViewModel.findUser)
            }
            .padding(.horizontal)
            .padding(.bottom)
            ScrollView(showsIndicators: false) {
                if (!createChatViewModel.load) {
                    ProgressView()
                } else {
                    ForEach(0..<createChatViewModel.following.count, id: \.self){index in
                        Button(action: {
                            createChatViewModel.createChat(userId: createChatViewModel.following[index].followOnUser.id) { newChat in
                                if let newChat = newChat{
                                    onCreated(newChat)
                                }
                            }
                        }) {
                            HStack(alignment: .top) {
                                if let avatar = createChatViewModel.following[index].followOnUser.avatar {
                                    WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                                        .resizable()
                                        .frame(width: 56, height: 56)
                                        .cornerRadius(16)
                                } else {
                                    DefaultAvatar(width: 56, height: 56, cornerRadius: 16)
                                }

                                VStack(alignment: .leading) {
                                    Text(createChatViewModel.following[index].followOnUser.login ?? "")
                                        .font(.custom(GothamBold, size: 14))
                                        .foregroundColor(Color(hex: "#2E313C"))
                                    Text("@login")
                                        .font(.custom(GothamBook, size: 14))
                                        .foregroundColor(Color(hex: "#2E313C"))
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .transition(.move(edge: .trailing))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                createChatViewModel.getFollowing()
            }
        }
    }
}
