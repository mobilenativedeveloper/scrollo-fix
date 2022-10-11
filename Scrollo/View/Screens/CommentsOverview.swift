//
//  CommentsOverview.swift
//  Scrollo
//
//  Created by Artem Strelnik on 05.10.2022.
//

import SwiftUI

struct CommentsOverview: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var keyboardHelper : KeyboardHelper = KeyboardHelper()
    
    @Binding var post : PostModel
    
    @StateObject var commentsViewModel: CommentsViewModel = CommentsViewModel()
    
    @State var profilePresent: Bool? = false
    
    var body: some View {
        VStack(spacing: 0){
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle.left.arrow.black")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                VStack(spacing: 4) {
                    Text("\(post.creator.login)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#828796"))
                    Text("комментарии")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundColor(Color(hex: "#2E313C"))
                }
                Spacer(minLength: 0)
                Image("rounded.squere.pencile")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .background(Color(hex: "#F9F9F9"))
            .zIndex(1)
            
            
            VStack(spacing: 0){
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
                        Spacer(minLength: 0)
                    }
                    else{
                        ScrollView {
                            ForEach(0..<commentsViewModel.comments.count, id: \.self) {index in
                                CommentCardView(comment: $commentsViewModel.comments[index], message: $commentsViewModel.content, profilePresent: $profilePresent)
                                    .padding(.bottom, 19)
                                    .transition(.opacity)
                                    .environmentObject(commentsViewModel)
                            }
                        }
                        
                    }
                } else {
                    Spacer(minLength: 0)
                    ProgressView()
                }
                
                
                VStack(spacing: 0) {
                    
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
                                    .aspectRatio(contentMode: .fit)
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
            .offset(y: -self.keyboardHelper.keyboardHeight)
            
        }
        .background(Color(hex: "#F9F9F9").edgesIgnoringSafeArea(.all))
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationView(isPresent: $profilePresent){
            NavigationView{
                ProfileView(userId: post.creator.id, isPresented: $profilePresent)
                    .ignoreDefaultHeaderBar
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            commentsViewModel.getPostComments(postId: post.id)
        }
    }
}
