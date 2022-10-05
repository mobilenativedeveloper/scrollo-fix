//
//  PostView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import UISheetPresentationControllerCustomDetent

enum PostListAnimation{
    case delete
    case created
    case none
}

struct PostView: View{
    @Binding var post: PostModel
    
    @EnvironmentObject var postViewModel: PostViewModel
    
    @State var isPostSettings: Bool = false
    @State private var deletePost: Bool = false
    
    @State private var animation: PostListAnimation = .none
    
    @State var isSharePresent: Bool = false
    
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
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
            .padding(.bottom, 13)
            TruncateTextView(text: post.content)
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
            .padding(.top, 17)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 9, x: 0, y: 0)
        .padding(.vertical, 13.5)
        .padding(.horizontal)
        .transition(.opacity)
        .alert(isPresented: self.$deletePost) {
            Alert(title: Text("Вы действительно хотите удалить публикацию?"), message: nil, primaryButton: .destructive(Text("Удалить")){
                self.animation = .delete
                postViewModel.removePost(postId: post.id) {
                    withAnimation(.easeInOut(duration: 0.3)){
                        postViewModel.posts.removeAll(where: {
                            $0.id == post.id
                        })
                    }
                    self.animation = .none
                }
            }, secondaryButton: .default(Text("Отменить")))
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

private struct TruncateTextView: View {
    @State private var fullPost: Bool = false
    var text: String
    let limitedTextLength: Int = 140
    
    var body: some View {
        if self.text.count > self.limitedTextLength {
            let index = self.text.index(self.text.startIndex, offsetBy: self.limitedTextLength)
            VStack(alignment: .leading) {
                if self.fullPost {
                    textWithHashtags(self.text, color: Color(hex: "#5B86E5"))
                        .font(Font.custom(GothamBook, size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                } else {
                    Group {
                        textWithHashtags(String(self.text.prefix(upTo: index)), color: Color(hex: "#5B86E5")) + Text("...") + Text(" ") + Text("Развернуть").foregroundColor(.blue)
                    }
                    .font(Font.custom(GothamBook, size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                }
            }
            .onTapGesture(perform: {
                withAnimation(.default) {
                    self.fullPost = true
                }
            })
        } else {
            textWithHashtags(self.text, color: Color(hex: "#5B86E5"))
                .font(Font.custom(GothamBook, size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
        }
    }
}

private struct PostActionsSheet: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
   let postId: String?
    
    @Binding var deletePost: Bool

   var body: some View {
       VStack {
           RoundedRectangle(cornerRadius: 40)
               .fill(Color(hex: "#F2F2F2"))
               .frame(width: 40, height: 4)
               .padding(.top, 15)
               .padding(.bottom, 24)
           HStack(spacing: 10) {
               CustomButtonPostSheet(title: "поделиться", image: "share_bottom_sheet")
               CustomButtonPostSheet(title: "ссылка", image: "link_bottom_sheet")
               CustomButtonPostSheet(title: "пожаловаться", image: "report_bottom_sheet")
           }
           .padding(.bottom)
           VStack {
               Spacer(minLength: 0)
               VStack(spacing: 0) {
                   Text("Добавить в избранное")
                       .font(.system(size: 12))
                       .foregroundColor(.black)
                       .padding(.bottom, 15)
                   Rectangle()
                       .fill(Color(hex: "#D8D2E5").opacity(0.25))
                       .frame(width: UIScreen.main.bounds.width - 42, height: 1)
               }
               .padding(.vertical, 13)
               VStack(spacing: 0) {
                   Text("Скрыть")
                       .font(.system(size: 12))
                       .foregroundColor(.black)
                       .padding(.bottom, 15)
                   Rectangle()
                       .fill(Color(hex: "#D8D2E5").opacity(0.25))
                       .frame(width: UIScreen.main.bounds.width - 42, height: 1)
               }
               .padding(.bottom, 13)
               VStack(spacing: 0) {
                   Text("Отменить подписку")
                       .font(.system(size: 12))
                       .foregroundColor(.black)
                       .padding(.bottom, 15)
                   Rectangle()
                       .fill(Color(hex: "#D8D2E5").opacity(0.25))
                       .frame(width: UIScreen.main.bounds.width - 42, height: 1)
               }
               .padding(.bottom, 13)
               Button(action: {
                   presentationMode.wrappedValue.dismiss()
                   deletePost.toggle()
               }){
                   VStack(spacing: 0) {
                       Text("Удалить")
                           .font(.system(size: 12))
                           .foregroundColor(Color(hex: "#EB5757"))
                           .padding(.bottom, 15)
                   }
               }
               Spacer(minLength: 0)
           }
           .frame(width: (UIScreen.main.bounds.width - 42))
           .background(
               RoundedRectangle(cornerRadius: 10)
                   .fill(Color(hex: "#FAFAFA"))
                   .modifier(RoundedEdge(width: 1, color: Color(hex: "#DFDFDF"), cornerRadius: 10))
           )
           Spacer()
       }
       .padding(.bottom, 24)
   }
   
   @ViewBuilder
   func CustomButtonPostSheet(title: String, image: String) -> some View {
       VStack {
           Image(image)
               .resizable()
               .aspectRatio(contentMode: .fit)
               .frame(width: 18, height: 18)
               .padding(.bottom, 1)
           Text(title)
               .font(.system(size: 12))
               .foregroundColor(.black)
       }
       .frame(width: (UIScreen.main.bounds.width - 42) / 3.2, height: ((UIScreen.main.bounds.width - 78) / 3) / 1.5, alignment: .center)
       .background(
           RoundedRectangle(cornerRadius: 10)
               .fill(Color(hex: "#FAFAFA"))
               .modifier(RoundedEdge(width: 1, color: Color(hex: "#DFDFDF"), cornerRadius: 10))
       )
   }
}

private struct ShareBottomSheet: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let postId: String
    @State var searchText: String = ""
    var body: some View{
        VStack(spacing: 0){
            RoundedRectangle(cornerRadius: 40)
                .fill(Color(hex: "#F2F2F2"))
                .frame(width: 40, height: 4)
                .padding(.bottom, 11)
                .padding(.top, 11)
            HStack(spacing: 0){
                Text("поделиться")
                    .font(.custom(GothamBold, size: 27))
                    .foregroundColor(Color(hex: "#2E313C"))
                    .textCase(.lowercase)
                Spacer()
                Button(action:{}){
                    Image("share.square.blue")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.bottom, 25)
            
            HStack(spacing: 0){
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#444A5E"))
                TextField("Найти", text: self.$searchText)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#DDE8E8"))
            )
            .padding(.bottom, 42)
            
            HStack(spacing: 0){
                Button(action:{}){
                    ShareUserView(image: "testUserPhoto", login: "Lana Smith")
                }
                Spacer()
                Button(action:{}){
                    ShareUserView(image: "testUserPhoto", login: "Joe Evans")
                }
                Spacer()
                Button(action: {}){
                    ShareUserView(image: "testUserPhoto", login: "Diana Slown")
                }
                Spacer()
                Button(action: {}){
                    ShareUserView(image: "testUserPhoto", login: "John Doe")
                }
            }
            .padding(.bottom, 21)
            .padding(.horizontal, 28)
            
            HStack(spacing: 0){
                Button(action:{}){
                    ShareUserView(image: "testUserPhoto", login: "Lana Smith")
                }
                Spacer()
                Button(action:{}){
                    ShareUserView(image: "testUserPhoto", login: "Joe Evans")
                }
                Spacer()
                Button(action: {}){
                    ShareUserView(image: "testUserPhoto", login: "Diana Slown")
                }
                Spacer()
                Button(action: {}){
                    ShareUserView(image: "testUserPhoto", login: "John Doe")
                }
            }
            .padding(.bottom, 25)
            .padding(.horizontal, 28)
            
            Button(action: {}){
                Text("Отправить")
                    .font(.system(size: 14))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(colors: [Color(hex: "#36DCD8"),Color(hex: "#5B86E5")], startPoint: .leading, endPoint: .trailing)
                            .cornerRadius(40)
                    )
            }
           
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }
}

struct ShareUserView: View{
    let image: String
    let login: String
    var body: some View{
        VStack(spacing: 0){
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 54, height: 54)
                .cornerRadius(10)
            Text(login)
                .foregroundColor(Color(hex: "#444A5E"))
                .font(.system(size: 12))
                .padding(.top, 10)
        }
    }
}
