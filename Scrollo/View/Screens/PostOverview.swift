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
    
    @StateObject var commentsViewModel: CommentsViewModel = CommentsViewModel()
    
    @Binding var post: PostModel
    
    @State var isPostSettings: Bool = false
    @State private var deletePost: Bool = false
    
    @State var isSharePresent: Bool = false
    
    @State var profilePresent: Bool = false
    
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
                        .onTapGesture {
                            withAnimation(.easeInOut){
                                profilePresent.toggle()
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
                    
                    if post.type == "STANDART" {
                        PostMediaCarouselView(images: post.files)
                            .padding(.horizontal)
                        
                        HStack(spacing: 5) {
                            SpringButton(
                                image: post.liked ? "heart_active" : "heart_inactive",
                                count: post.likesCount,
                                ifDelivered: post.liked) {
                                    if !post.disliked{
                                        if post.liked {
                                            postViewModel.removeLike(postId: post.id) {
                                                post.liked.toggle()
                                                post.likesCount = post.likesCount - 1
                                            }
                                        }
                                        else{
                                            postViewModel.addLike(postId: post.id) {
                                                post.liked.toggle()
                                                post.likesCount = post.likesCount + 1
                                            }
                                        }
                                    }
                                }
                            SpringButton(
                                image: post.disliked ? "dislike_active" : "dislike_inactive",
                                count: post.dislikeCount,
                                ifDelivered: post.disliked) {
                                    if !post.liked{
                                        if post.disliked {
                                            postViewModel.removeDislike(postId: post.id) {
                                                post.disliked.toggle()
                                                post.dislikeCount = post.dislikeCount - 1
                                            }
                                        }
                                        else{
                                            postViewModel.addDislike(postId: post.id) {
                                                post.disliked.toggle()
                                                post.dislikeCount = post.dislikeCount + 1
                                            }
                                        }
                                    }
                            }
                            NavigationLink(destination: CommentsOverview(post: $post)
                                            .ignoreDefaultHeaderBar){
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
                    
                    Text(post.content)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    if post.type == "TEXT" {
                        HStack(spacing: 5) {
                            SpringButton(
                                image: post.liked ? "heart_active" : "heart_inactive",
                                count: post.likesCount,
                                ifDelivered: post.liked) {
                                    if !post.disliked{
                                        if post.liked {
                                            postViewModel.removeLike(postId: post.id) {
                                                post.liked.toggle()
                                                post.likesCount = post.likesCount - 1
                                            }
                                        }
                                        else{
                                            postViewModel.addLike(postId: post.id) {
                                                post.liked.toggle()
                                                post.likesCount = post.likesCount + 1
                                            }
                                        }
                                    }
                                }
                            SpringButton(
                                image: post.disliked ? "dislike_active" : "dislike_inactive",
                                count: post.dislikeCount,
                                ifDelivered: post.disliked) {
                                    if !post.liked{
                                        if post.disliked {
                                            postViewModel.removeDislike(postId: post.id) {
                                                post.disliked.toggle()
                                                post.dislikeCount = post.dislikeCount - 1
                                            }
                                        }
                                        else{
                                            postViewModel.addDislike(postId: post.id) {
                                                post.disliked.toggle()
                                                post.dislikeCount = post.dislikeCount + 1
                                            }
                                        }
                                    }
                            }
                            NavigationLink(destination: CommentsOverview(post: $post)
                                            .ignoreDefaultHeaderBar){
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
                            WebImage(url: URL(string: "https://picsum.photos/200/300?random=1"))
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
                            WebImage(url: URL(string: "https://picsum.photos/200/300?random=2"))
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
                            WebImage(url: URL(string: "https://picsum.photos/200/300?random=3"))
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
                if commentsViewModel.load {
                    if commentsViewModel.comments.count == 0{
                        Spacer(minLength: 0)
                        VStack(alignment: .center) {
                            
                            Text("Нет комментариев.")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.black)
                                .padding(.bottom, 5)
                            Text("Начните переписку")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 40)
                        }
                    }
                    else{
                        ForEach(0..<commentsViewModel.comments.count, id: \.self) {index in
                            CommentCardView(comment: $commentsViewModel.comments[index], message: $commentsViewModel.content)
                                .padding(.bottom, 19)
                                .padding(.horizontal)
                                .transition(.opacity)
                                .environmentObject(commentsViewModel)
                        }
                    }
                    
                } else {
                    ProgressView()
                }
            }
            
            Spacer(minLength: 0)
            
            VStack(spacing: 0){
                if commentsViewModel.reply != nil {
                    HStack(alignment: .top){
                        Text("Ваш ответ \(commentsViewModel.reply!.login)")
                            .foregroundColor(Color(hex: "#a8a8a8"))
                        Spacer(minLength: 0)
                        Button(action: {
                            withAnimation(.easeInOut){
                                commentsViewModel.reply = nil
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(hex: "#000000"))
                        }
                    }
                    .padding(.all, 10)
                    .background(Color(hex: "#efefef"))
                    .transition(.opacity)
                }
                VStack(spacing: 0) {
                    EmojiListView(comment: $commentsViewModel.content)
                        .padding(.vertical, 5)
                        .padding(.bottom)
                        .padding(.horizontal)
                    HStack {
                        TextField("Добавьте комментарий...", text: $commentsViewModel.content)
                        Button(action: {
                            if !commentsViewModel.content.isEmpty{
                                if commentsViewModel.reply == nil{
                                    commentsViewModel.addComment(postId: post.id) {
                                        commentsViewModel.content = String()
                                        UIApplication.shared.endEditing()
                                    }
                                }
                                else{
                                    if let postCommentId = commentsViewModel.reply?.postCommentId {
                                        commentsViewModel.addReply(postCommentId: postCommentId) {
                                            commentsViewModel.content = String()
                                            UIApplication.shared.endEditing()
                                            commentsViewModel.reply = nil
                                        }
                                    }
                                }
                            }
                        }) {
                            Image("send.comment.button")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fill)
                                .opacity(commentsViewModel.content.isEmpty ? 0 : 1)
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
        .navigationView(isPresent: $profilePresent){
            ProfileView(userId: post.creator.id)
        }
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
        .onAppear {
            commentsViewModel.getPostComments(postId: post.id)
        }
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


