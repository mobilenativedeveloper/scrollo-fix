//
//  CreateNewChatView.swift
//  scrollo
//
//  Created by Artem Strelnik on 26.08.2022.
//

import SwiftUI
//import Introspect
import SDWebImageSwiftUI

struct CreateNewChatView: View {
    @ObservedObject var createChatViewModel : CreateChatViewModel = CreateChatViewModel()
    @Binding var presentNewChat: Bool
    var onCreated: (ChatListModel.ChatModel)->Void
    var body: some View {
        VStack {
            HeaderBar(presentNewChat: $presentNewChat)
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

private struct HeaderBar: View {
    @Binding var presentNewChat: Bool
    var body: some View{
        HStack(spacing: 0) {
            Button(action: {
                withAnimation{
                    presentNewChat.toggle()
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
                Image("circle.right.arrow")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
        }
        .padding(.horizontal, 23)
        .padding(.bottom)
    }
}
