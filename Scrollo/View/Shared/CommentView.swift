//
//  CommentView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 05.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct CommentCardView : View {
    @EnvironmentObject var commentsViewModel: CommentsViewModel
    @Binding var comment : PostModel.CommentsModel
    @Binding var message : String
    
    var body : some View {

        VStack(spacing: 0) {

            CommentView(comment: comment, onPressLike: {
                if let liked = comment.liked{
                    if liked {
                        commentsViewModel.likeRemoveComment(postCommentId: comment.id) {
                            comment.liked?.toggle()
                            comment.likesCount = comment.likesCount! - 1
                        }
                    }
                    else{
                        commentsViewModel.likeComment(postCommentId: comment.id) {
                            comment.liked?.toggle()
                            comment.likesCount = comment.likesCount! + 1
                        }
                    }
                }
            }, onPressReply: {
                withAnimation(.easeInOut){
                    commentsViewModel.reply = Reply(postCommentId: comment.id, login: self.comment.user.login)
                }
            }, onRemove: {
                
            })
                .padding(.bottom, 19)
            ForEach(0..<comment.lastSubComments.count, id: \.self) {index in
                let replyComment = comment.lastSubComments[index]
                SubCommentView(comment: replyComment, onPressLike: {
                   
                    if let liked = replyComment.liked{
                        if liked {
                            commentsViewModel.replyLikeRemove(postCommentId: comment.id, postCommentReplyId: replyComment.id) {
                                guard let replyIndex = comment.lastSubComments.firstIndex(where: {$0.id == replyComment.id}) else {return}
                                        
                                comment.lastSubComments[replyIndex].liked!.toggle()
                                comment.lastSubComments[replyIndex].likesCount = comment.lastSubComments[replyIndex].likesCount! - 1
                            }
                        }
                        else{
                            commentsViewModel.replyLike(postCommentId: comment.id, postCommentReplyId: replyComment.id) {
                                guard let replyIndex = comment.lastSubComments.firstIndex(where: {$0.id == replyComment.id}) else {return}

                                comment.lastSubComments[replyIndex].liked = true
                                comment.lastSubComments[replyIndex].likesCount = comment.lastSubComments[replyIndex].likesCount! + 1
                            }
                        }
                    }
                }, onPressReply: {
                    withAnimation(.easeInOut){
                        commentsViewModel.reply = Reply(postCommentId: comment.id, login: replyComment.user.login)
                    }
                }, onRemove: {
                    
                })
                    .padding(.leading, 48)
                    .padding(.bottom)
            }
        }
    }
}

private struct CommentView: View{
    var comment : PostModel.CommentsModel
    var onPressLike: ()->()
    var onPressReply: () -> ()
    var onRemove: () -> ()
    
    @State var offset: CGFloat = .zero
    @State var isSwiped: Bool = false
    
    var body: some View{
        ZStack{
            LinearGradient(gradient: .init(colors: [Color(hex: "#f55442"), Color(hex: "#fa6c5c").opacity(0.5)]), startPoint: .trailing, endPoint: .leading)
                
            HStack{
                Spacer(minLength: 90)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onRemove()
                        offset = 0
                    }
                }){
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 90)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    if let avatar = comment.user.avatar {
                        AnimatedImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .padding(.trailing, 16)
                    } else {
                        DefaultAvatar(width: 32, height: 32, cornerRadius: 10)
                            .padding(.trailing, 16)
                    }
                    Text(comment.user.login).foregroundColor(.black).font(.custom(GothamBold, size: 14)) + Text("  ") + textWithHashtags(comment.comment, color: Color(hex: "#5B86E5")).font(.custom(GothamBook, size: 12)).foregroundColor(Color(hex: "#828282"))
                    Spacer()
                    Text("3ч")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#828282"))

                }
                HStack(spacing: 0) {
                    Button(action: {
                        onPressLike()
                    }) {
                        HStack(spacing: 0) {
                            if let liked = comment.liked {
                                if liked {
                                    Image("heart_active")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                } else {
                                    Image("heart_comment_inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                }
                                if (comment.likesCount ?? 0) > 0 {
                                    Text("\(comment.likesCount!)")
                                        .font(.custom(GothamBold, size: 10))
                                        .foregroundColor(liked ? Color(hex: "#FF0F82") : Color(hex: "#000000"))
                                        .padding(.leading, 4)
                                }
                            }

                        }
                    }
                    .padding(.trailing, 8)
                    Button(action: {
                        onPressReply()
                    }) {
                        HStack(spacing: 0) {
                            Image(comment.lastSubComments.count > 0 ? "comment_reply_active" : "comment_reply_inactive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            if comment.lastSubComments.count > 0 {
                                Text("\(comment.lastSubComments.count)")
                                    .font(.custom(GothamBold, size: 10))
                                    .foregroundColor(.black)
                                    .padding(.leading, 4)
                            }
                        }
                    }
                }
                .padding(.top, 9)
                .padding(.leading, 48)
            }
            .padding(.horizontal)
            .background(Color(hex: "#F9F9F9"))
            .offset(x: offset)
            .gesture(DragGesture().onChanged(onChange(value:)).onEnded(onEnd(value:)))
            
        }
    }
    func onChange(value: DragGesture.Value){
        if value.translation.width < 0 {
            if self.isSwiped {
                self.offset = value.translation.width - 90
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
                    self.offset = -90
                }
                else if -self.offset > 50{
                    self.isSwiped = true
                    self.offset = -90
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
}

private struct SubCommentView: View{
    var comment : PostModel.LastSubComments
    var onPressLike: ()->()
    var onPressReply: () -> ()
    var onRemove: () -> ()
    
    @State var offset: CGFloat = .zero
    @State var isSwiped: Bool = false
    
    var body: some View{
        ZStack{
            LinearGradient(gradient: .init(colors: [Color(hex: "#f55442"), Color(hex: "#fa6c5c").opacity(0.5)]), startPoint: .trailing, endPoint: .leading)
                
            HStack{
                Spacer(minLength: 90)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onRemove()
                    }
                }){
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 90)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    if let avatar = comment.user.avatar {
                        AnimatedImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .padding(.trailing, 16)
                    } else {
                        DefaultAvatar(width: 32, height: 32, cornerRadius: 10)
                            .padding(.trailing, 16)
                    }
                    Text(comment.user.login).foregroundColor(.black).font(.custom(GothamBold, size: 14)) + Text("  ") + textWithHashtags(comment.content, color: Color(hex: "#5B86E5")).font(.custom(GothamBook, size: 12)).foregroundColor(Color(hex: "#828282"))
                    Spacer()
                    Text("3ч")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "#828282"))

                }
                HStack(spacing: 0) {
                    Button(action: {
                        onPressLike()
                    }) {
                        HStack(spacing: 0) {
                            if let liked = comment.liked {
                                if liked {
                                    Image("heart_active")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                } else {
                                    Image("heart_comment_inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                }
                                if (comment.likesCount ?? 0) > 0 {
                                    Text("\(comment.likesCount!)")
                                        .font(.custom(GothamBold, size: 10))
                                        .foregroundColor(liked ? Color(hex: "#FF0F82") : Color(hex: "#000000"))
                                        .padding(.leading, 4)
                                }
                            }

                        }
                    }
                    .padding(.trailing, 8)
                    Button(action: {
                        onPressReply()
                    }) {
                        HStack(spacing: 0) {
                            Image("comment_reply_inactive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .padding(.top, 9)
                .padding(.leading, 48)
            }
            .padding(.horizontal)
            .background(Color(hex: "#F9F9F9"))
            .offset(x: offset)
            .gesture(DragGesture().onChanged(onChange(value:)).onEnded(onEnd(value:)))
        }
        
    }
    
    func onChange(value: DragGesture.Value){
        if value.translation.width < 0 {
            if self.isSwiped {
                self.offset = value.translation.width - 90
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
                    self.offset = -90
                }
                else if -self.offset > 50{
                    self.isSwiped = true
                    self.offset = -90
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
}
//struct CommentView : View {
//    @EnvironmentObject var commentsViewModel: CommentsViewModel
//    @Binding var comment : PostModel.CommentsModel
////    @Binding var reply : Reply
//    @Binding var message : String
//
//    @State var isReply: PostModel.CommentsModel?
//
//    var body : some View {
//
//        VStack(spacing: 0) {
//
//            self.content(avatar: comment.user.avatar, login: comment.user.login, content: comment.comment, liked: comment.liked, likesCount: comment.likesCount, replyCount: comment.lastSubComments.count, postCommentId: comment.id, replyId: nil)
//                .padding(.bottom, 19)
//
//            ForEach(0..<comment.lastSubComments.count, id: \.self) {index in
//                let replyComment = comment.lastSubComments[index]
//
//                self.content(avatar: replyComment.user.avatar, login: replyComment.user.login, content: replyComment.content, liked: replyComment.liked, likesCount: replyComment.likesCount, replyCount: 0, postCommentId: comment.id, replyId: replyComment.id)
//                    .padding(.leading, 48)
//                    .padding(.bottom)
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func content(avatar: String?, login: String, content: String, liked: Bool?, likesCount: Int?, replyCount: Int, postCommentId: String, replyId: String?) -> some View {
//
//        VStack(alignment: .leading, spacing: 0) {
//
//            HStack(alignment: .top, spacing: 0) {
//                if let avatar = avatar {
//                    AnimatedImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 32, height: 32)
//                        .background(Color.gray)
//                        .cornerRadius(10)
//                        .padding(.trailing, 16)
//                } else {
//                    DefaultAvatar(width: 32, height: 32, cornerRadius: 10)
//                        .padding(.trailing, 16)
//                }
//                Text(login).foregroundColor(.black).font(.custom(GothamBold, size: 14)) + Text("  ") + textWithHashtags(content, color: Color(hex: "#5B86E5")).font(.custom(GothamBook, size: 12)).foregroundColor(Color(hex: "#828282"))
//                Spacer()
//                Text("3ч")
//                    .font(.system(size: 10))
//                    .foregroundColor(Color(hex: "#828282"))
//
//            }
//            HStack(spacing: 0) {
//                Button(action: {
//                    guard let like = liked else {return}
//                    if like{
//                        if let replyId  = replyId{
//                            commentsViewModel.replyLikeRemove(postCommentId: postCommentId, postCommentReplyId: replyId)
//                        }
//                        else{
//                            commentsViewModel.likeRemoveComment(postCommentId: postCommentId)
//                        }
//                    }
//                    else{
//                        if let replyId = replyId{
//                            commentsViewModel.replyLike(postCommentId: postCommentId, postCommentReplyId: replyId)
//                        }
//                        else{
//                            commentsViewModel.likeComment(postCommentId: postCommentId)
//                        }
//                    }
//                }) {
//                    HStack(spacing: 0) {
//                        if let liked = liked {
//                            if liked {
//                                Image("heart_active")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 16, height: 16)
//                            } else {
//                                Image("heart_comment_inactive")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 16, height: 16)
//                            }
//                            if (likesCount ?? 0) > 0 {
//                                Text("\(likesCount!)")
//                                    .font(.custom(GothamBold, size: 10))
//                                    .foregroundColor(liked ? Color(hex: "#FF0F82") : Color(hex: "#000000"))
//                                    .padding(.leading, 4)
//                            }
//                        }
//
//                    }
//                }
//                .padding(.trailing, 8)
//                Button(action: {
//
//
//                }) {
//                    HStack(spacing: 0) {
//                        Image(replyCount > 0 ? "comment_reply_active" : "comment_reply_inactive")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 16, height: 16)
//                        if replyCount > 0 {
//                            Text("\(replyCount)")
//                                .font(.custom(GothamBold, size: 10))
//                                .foregroundColor(.black)
//                                .padding(.leading, 4)
//                        }
//                    }
//                }
//            }
//            .padding(.top, 9)
//            .padding(.leading, 48)
//        }
//    }
//}
