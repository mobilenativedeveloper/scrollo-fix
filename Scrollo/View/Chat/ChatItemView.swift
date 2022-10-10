//
//  ChatItemView.swift
//  scrollo
//
//  Created by Artem Strelnik on 14.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatItemView: View{
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State var offset: CGFloat = .zero
    @State var isSwiped: Bool = false
    @Binding var chat: ChatListModel.ChatModel
    @Binding var chatList: [ChatListModel.ChatModel]
    
    var body: some View {
        NavigationLink(destination: ChatMessagesView(user: chat.receiver).ignoreDefaultHeaderBar) {
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
                    self.isSwiped = true
                    self.offset = -180
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
