//
//  FavoriteContactView.swift
//  scrollo
//
//  Created by Artem Strelnik on 14.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoriteContactView : View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    var chat: ChatListModel.ChatModel
    var body : some View {
        NavigationLink(destination: ChatMessagesView(user: chat.receiver).ignoreDefaultHeaderBar) {
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
