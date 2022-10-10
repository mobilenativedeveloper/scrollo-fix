//
//  DetailUserView.swift
//  scrollo
//
//  Created by Artem Strelnik on 15.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailUserView: View {
    var user: ChatListModel.ChatModel.ChatUser
    @Binding var profilePresent: Bool
    var body: some View {
        VStack(spacing: 0){
            if let avatar = user.avatar {
                WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .padding(.bottom, 6)
            } else {
                DefaultAvatar(width: 70, height: 70, cornerRadius: 6)
                    .padding(.trailing, 7)
            }
            Text("Name Lastname")
                .font(.system(size: 14))
                .fontWeight(.bold)
                .padding(.bottom, 3)
            Text("login • Scrollo")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#838383"))
                .padding(.bottom, 1)
            Text("Подписчики: 135 • Публикации: 0")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#838383"))
                .padding(.bottom, 8)
            Button(action: {
                withAnimation{
                    profilePresent = true
                }
            }){
                Text("Посмотреть профиль")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .background(Color(hex: "#efefef").cornerRadius(8))
            }
        }
    }
}
