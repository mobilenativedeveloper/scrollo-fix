//
//  PostOverview.swift
//  Scrollo
//
//  Created by Artem Strelnik on 05.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostOverview: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @EnvironmentObject var postViewModel: PostViewModel
    
    @Binding var post: PostModel
    @State var comment: String = ""
    
    @State var isPostSettings: Bool = false
    @State private var deletePost: Bool = false
    
    @State var isSharePresent: Bool = false
    
    var body: some View {
        VStack(alignment: .leading){
            ScrollView{
                VStack(alignment: .leading){
                    HStack(spacing: 0) {
                        HStack(spacing: 0){
                            Avatar()
                            VStack(alignment: .leading, spacing: 0) {
                                Text(post.creator.login)
                                    .font(.system(size: 14))
                                    .fontWeight(Font.Weight.bold)
                                    .foregroundColor(Color(hex: "#333333"))
                                    .offset(y: -5)
                                if let place = post.place {
                                    Text("\(place.name)")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#909090"))
                                } else {
                                    Text("")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#909090"))
                                }
                            }
                        }
                        Spacer()
                        Button(action: {
                            self.isPostSettings.toggle()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "#4F4F4F"))
                                        .rotationEffect(Angle(degrees: 90))
                                )
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
                        .offset(x: 14)
                        .bottomSheet(isPresented: $isPostSettings, detents: [.custom(360)]) {
                            PostActionsSheet(postId: post.id, deletePost: $deletePost)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    .background(Color.white)
//                    if post.type == "STANDART" {
//                        if let files = post.files {
//                            PostMediaCarousel(images: files)
//                                .padding(.horizontal)
//                            PostFooter(post: $post)
//                                .padding(.top, 17)
//                                .padding(.horizontal)
//                                .environmentObject(bottomSheetViewModel)
//                        }
//                    }
                    Text(post.content)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    if post.type == "TEXT" {
                        HStack(spacing: 5) {
                            Button(action: {
                                
                            }) {
                                HStack(spacing: 0) {
                                    Image(post.liked ? "heart_active" : "heart_inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21, height: 21)
                                        .padding(.trailing, 6)
                                    if let count = post.likesCount {
                                        Text("\(count)")
                                            .font(Font.custom(GothamBold, size: 12))
                                            .foregroundColor(Color.black)
                                    }
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 6)
                            .background(post.liked ? Color(hex: "#F0F0F0") : Color.clear)
                            .cornerRadius(30)
                            Button(action: {
                              
                            }) {
                                HStack(spacing: 0) {
                                    Image(post.disliked ? "dislike_active" : "dislike_inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21, height: 21)
                                        .padding(.trailing, 6)
                                    if let count = post.dislikeCount {
                                        Text("\(count)")
                                            .font(Font.custom(GothamBold, size: 12))
                                            .foregroundColor(Color.black)
                                    }
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal, 17)
                            .padding(.vertical, 6)
                            .background(post.disliked ? Color(hex: "#F0F0F0") : Color.clear)
                            .cornerRadius(30)
                            Button(action: {
                                
                            }) {
                                HStack(spacing: 0) {
                                    Image("comments")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21, height: 21)
                                        .padding(.trailing, 6)
                                    Text("\(post.commentsCount)")
                                        .font(Font.custom(GothamBold, size: 12))
                                        .foregroundColor(Color.black)
                                }
                                .frame(width: 61, height: 20)
                            }
                            Button(action: {
                                self.isSharePresent.toggle()
                            }) {
                                Image("share")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 21, height: 21)
                            }
                            .frame(width: 61, height: 20)
                            .bottomSheet(isPresented: $isSharePresent, detents: [.custom(440)]) {
                                ShareBottomSheet(postId: post.id)
                            }
                            Spacer(minLength: 0)
                            Button(action: {
                                
                            }) {
                                if post.inSaved {
                                    Image("bookmark_active")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21, height: 21)
                                } else {
                                    Image("bookmark_inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 21, height: 21)
                                }

                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 17)
                    }
                    
                    HStack(spacing: 0) {
                        ZStack{
                            Image("story1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 18, height: 18)
                                .background(Color(hex: "#F2F2F2"))
                                .clipShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#F2F2F2"))
                                        .frame(width: 20, height: 20)
                                )
                            Image("story2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 18, height: 18)
                                .background(Color(hex: "#F2F2F2"))
                                .clipShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#F2F2F2"))
                                        .frame(width: 20, height: 20)
                                )
                                .offset(x: 10)
                            Image("story3")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 18, height: 18)
                                .background(Color(hex: "#F2F2F2"))
                                .clipShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#F2F2F2"))
                                        .frame(width: 20, height: 20)
                                )
                                .offset(x: 20)
                        }
                        .padding(.trailing, 35)
                        Text("нравится Mike_Bulkin и еще 524 людям")
                            .font(Font.custom(GothamBold, size: 11))
                            .padding(.trailing, 3)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .padding(.top, 5)
                }
                .background(Color.white)
                .clipShape(CustomCorner(radius: 17, corners: [.bottomRight, .bottomLeft]))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 20)
                .padding(.bottom, 25)
                //MARK: Comments
            }
            
            Spacer(minLength: 0)
            
            VStack(spacing: 0){
                VStack(spacing: 0) {
                    EmojiListView(comment: $comment)
                        .padding(.vertical, 5)
                        .padding(.bottom)
                        .padding(.horizontal)
                    HStack {
                        TextField("Добавьте комментарий...", text: $comment)
                        Button(action: {
                            
                        }) {
                            Image("send.comment.button")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fill)
                                .opacity(comment.isEmpty ? 0 : 1)
                        }
                    }
                    .frame(height: 45)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 10.0)
                            .strokeBorder(Color(hex: "#EFEFF4"), style: StrokeStyle(lineWidth: 1.0))
                            
                    )
                    .padding(.horizontal, 5)
                }
                .padding(.horizontal, 8)
                .padding()
            }
            .padding(.bottom)
            .background(Color.white)
            .clipShape(CustomCorner(radius: 20, corners: [.topLeft, .topRight]))
            .shadow(color: Color(hex: "#282828").opacity(0.03), radius: 10, x: 0, y: -14)
        }
        .background(Color(hex: "#F9F9F9").edgesIgnoringSafeArea(.all))
        .ignoresSafeArea(.container, edges: [.bottom, .top])
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
    }
    @ViewBuilder
    func Avatar() -> some View{
        if let avatar = post.creator.avatar{
            WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)"))
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipped()
                .cornerRadius(10)
                .padding(.trailing, 7)
        }
        else{
            DefaultAvatar(width: 35, height: 35, cornerRadius: 10)
                .clipped()
                .padding(.trailing, 7)
        }
    }
}


