//
//  PostView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import UISheetPresentationControllerCustomDetent
import AVKit

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
    
    @State var mediaPostSaveAlbumPresent: Bool = false
    
    @State var isPresentedProfile: Bool? = nil
    
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                NavigationLink(destination: ProfileView(userId: post.creator.id, isPresented: $isPresentedProfile)
                                .ignoreDefaultHeaderBar){
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
                    PostActionsSheet(postId: post.id, userId: post.creator.id, deletePost: $deletePost)
                }
            }
            .padding(.bottom, 13)
            
            if post.type == "STANDART"{
                PostMediaCarouselView(images: post.files)
                    .padding(.bottom, 16)
            }
            
            TruncateTextView(text: post.content)
            
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
                    if post.type == "TEXT"{
                        if post.inSaved {
                            postViewModel.unSavePost(postId: post.id) {
                                post.inSaved = false
                            }
                        }
                        else{
                            postViewModel.savePost(postId: post.id, albumId: nil) {
                                post.inSaved = true
                            }
                        }
                    }
                    if post.type == "STANDART"{
                        if post.inSaved {
                            postViewModel.unSavePost(postId: post.id) {
                                post.inSaved = false
                            }
                        }
                        else{
                            mediaPostSaveAlbumPresent.toggle()
                        }
                        
                    }
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
            .background(Color.white)
            .fullScreenCover(isPresented: $mediaPostSaveAlbumPresent) {
                SelectAlbum(isPresented: $mediaPostSaveAlbumPresent, post: $post)
            }
            if post.type == "STANDART"{
                ShareUsersPost()
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 14)
        .background(
            NavigationLink(destination: PostOverview(post: $post)
                            .environmentObject(postViewModel)
                            .ignoreDefaultHeaderBar){
                                Color.white
                            }
                .buttonStyle(FlatLinkStyle())
        )
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

struct SpringButton: View{
    var image: String
    var count: Int
    var ifDelivered: Bool
    var action: ()->()
    
    @State var animated: Bool = false
    
    var body: some View{
        HStack(spacing: 0) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 21, height: 21)
                .padding(.trailing, 6)
            if let count = self.count {
                Text("\(count)")
                    .font(Font.custom(GothamBold, size: 12))
                    .foregroundColor(Color.black)
            }
        }
        .frame(height: 20)
        .padding(.horizontal, 17)
        .padding(.vertical, 6)
        .background(ifDelivered ? Color(hex: "#F0F0F0").scaleEffect(self.animated ? 0.9 : 1) : Color.clear.scaleEffect(self.animated ? 0.9 : 1))
        .cornerRadius(30)
        .scaleEffect(self.animated ? 0.9 : 1)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)){self.animated = true}
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                withAnimation(.spring()){self.animated = false}
            }
            action()
        }
    }
}

struct TruncateTextView: View {
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

struct PostActionsSheet: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
   let postId: String?
    let userId: String
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
                   if UserDefaults.standard.string(forKey: "userId") == userId{
                       presentationMode.wrappedValue.dismiss()
                       deletePost.toggle()
                   }
                   
               }){
                   VStack(spacing: 0) {
                       Text("Удалить")
                           .font(.system(size: 12))
                           .foregroundColor(Color(hex: "#EB5757"))
                           .padding(.bottom, 15)
                   }
               }
               .opacity(UserDefaults.standard.string(forKey: "userId") == userId ? 1 : 0)
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

struct ShareBottomSheet: View{
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

struct PostMediaCarouselView: View {
    @State var selection : Int = 0
    
    var images: [PostModel.PostFiles]
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            VStack {
                TabView(selection: self.$selection) {
                    ForEach(0..<images.count, id: \.self){index in
                        if images[index].type == "IMAGE" {
                            if let path = self.images[index].filePath {
                                WebImage(url: URL(string: "\(API_URL)/uploads/\(path)")!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: UIScreen.main.bounds.width - 48)
                                    .clipped()
                                    .tag(index)
                            }
                        } else if images[index].type == "VIDEO" {
                            if let path = images[index].filePath {
                                SlideVideo(path: path)
                                    .tag(index)
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .frame(height: UIScreen.main.bounds.width - 48)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 9, x: 0, y: 0)
            Indicator()
        }
    }
    
    @ViewBuilder
    func Indicator() -> some View {
        HStack {
            ForEach(0..<images.count, id: \.self) {index in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: self.selection == index ? 28 : 7, height: 4)
                    .padding(.trailing, index != images.count - 1 ? 4 : 0)
                    .animation(.default)
            }
        }
        .offset(x: -10, y: 10)
    }
}

struct SlideVideo: View {
    @StateObject var videoThumbnailViewModel: VideoThumbnailViewModel = VideoThumbnailViewModel()
    @State var playVideo: Bool = false
    var path: String
    let player = AVPlayer(url:  URL(string: "https://images.all-free-download.com/footage_preview/mp4/jasmine_flower_6891520.mp4")!)
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            if self.playVideo == false {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    Image(uiImage: videoThumbnailViewModel.thumbnailVideo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.width - 48)
                        .clipped()
                        .background(Color(hex: "#f2f2f2"))
                        .overlay(
                            ProgressView(),
                            alignment: Alignment(horizontal: .center, vertical: .center)
                        )
                    if !videoThumbnailViewModel.load {
                        ProgressView()
                    } else {
                        Image("play_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 73, height: 73)
                    }
                }
                .frame(height: UIScreen.main.bounds.width - 48)
                .background(Color(hex: "#383838"))
                .onTapGesture(perform: {
                    if videoThumbnailViewModel.load {
                        if self.playVideo == true {
                            self.playVideo = false
                        } else {
                            self.playVideo = true
                        }
                    }
                })
            } else {
                PlayerControllerRepresented(player: AVPlayer(url: URL(string: "\(API_URL)/uploads/\(path)")!))
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.width - 48)
                    .onAppear(perform: {
                        print("UIAVPlayerControllerRepresented play")
                        player.play()
                    })
            }
        }
        .frame(height: UIScreen.main.bounds.width - 48)
        .onAppear{
            if !videoThumbnailViewModel.error {
                videoThumbnailViewModel.createThumbnailFromVideo(url: URL(string: "\(API_URL)/uploads/\(path)")!)
            }
        }
        .onTapGesture(perform: {
            if videoThumbnailViewModel.load {
                if self.playVideo == true {
                    self.playVideo = false
                } else {
                    self.playVideo = true
                }
            }
        })
    }
}

struct PlayerControllerRepresented : UIViewControllerRepresentable {
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

struct ShareUsersPost: View {
    var body: some View {
        HStack(spacing: 0) {
            ZStack{
                WebImage(url: URL(string: "https://picsum.photos/200/300?random=1")!)
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
                WebImage(url: URL(string: "https://picsum.photos/200/300?random=2")!)
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
                WebImage(url: URL(string: "https://picsum.photos/200/300?random=3")!)
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
            Text("Привет друзья, как вы? Хочу поделиться новостями...")
                .font(Font.custom(GothamBook, size: 11))
                .padding(.trailing, 3)
            Spacer(minLength: 0)
            Button(action: {}){
                Text("Далее")
                    .font(Font.custom(GothamBook, size: 10))
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
            }
            .background(Color(hex: "#F0F0F0"))
            .cornerRadius(50)
        }
        .padding(.top, 20)
    }
}

struct SelectAlbum: View {
    @Binding var isPresented: Bool
    @Binding var post: PostModel
    
    @ObservedObject var postViewModel: PostViewModel = PostViewModel()
    
    @StateObject var albumsViewModel: AlbumsViewModel = AlbumsViewModel()
    
    let savedItemSize: CGFloat = (screen_rect.width / 2) - 26 - 9
    
    @State var createAlbumPresent: Bool = false
    
    var body: some View{
        VStack{
            HStack {
                Button(action: {
                    withAnimation{
                        isPresented.toggle()
                    }
                }) {
                    Image("circle_close")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("Сохранить в")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                    withAnimation{
                        createAlbumPresent.toggle()
                    }
                }) {
                    
                    Image("blue.circle.outline.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            if albumsViewModel.load{
                if albumsViewModel.albumsComposition.count > 0{
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(0..<albumsViewModel.albumsComposition.count, id: \.self){index in
                                HStack(spacing: 0) {
                                    if albumsViewModel.albumsComposition[index].count >= 1 {
                                        SavedItem(album: albumsViewModel.albumsComposition[index][0])
                                            .onTapGesture {
                                                postViewModel.savePost(postId: post.id, albumId: albumsViewModel.albumsComposition[index][0].id) {
                                                    post.inSaved = true
                                                    isPresented.toggle()
                                                }
                                            }
                                    }
                                    Spacer(minLength: 0)
                                    if albumsViewModel.albumsComposition[index].count == 2 {
                                        SavedItem(album: albumsViewModel.albumsComposition[index][1])
                                            .onTapGesture {
                                                postViewModel.savePost(postId: post.id, albumId: albumsViewModel.albumsComposition[index][1].id) {
                                                    post.inSaved = true
                                                    isPresented.toggle()
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding([.horizontal, .top])
                    }
                }
                else{
                    
                }
            }
            else{
                Spacer(minLength: 0)
                ProgressView()
            }
            
            Spacer(minLength: 0)
        }
        .onAppear(perform: {
            albumsViewModel.getAlbums(composition: true)
        })
        .fullScreenCover(isPresented: $createAlbumPresent, content: {
            CreateAlbumView(isPresent: $createAlbumPresent)
                .environmentObject(albumsViewModel)
        })
    }
    
    @ViewBuilder
    private func SavedItem(album: AlbumModel) -> some View {
        VStack {
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    if album.preview.count >= 1 {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(album.preview[0])"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    } else {
                        Color(hex: "#efefef")
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    }
                    
                    if album.preview.count >= 2 {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(album.preview[1])"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    } else {
                        Color(hex: "#efefef")
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    }
                }
                HStack(spacing: 1) {
                    if album.preview.count >= 3 {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(album.preview[2])"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    } else {
                        Color(hex: "#efefef")
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    }
                    
                    if album.preview.count >= 4 {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(album.preview[3])"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    } else {
                        Color(hex: "#efefef")
                            .frame(width: savedItemSize / 2, height: savedItemSize / 2)
                            .cornerRadius(6)
                    }
                }
                
            }
            .frame(width: savedItemSize, height: savedItemSize)
            .clipped()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1)
                    )
                    .frame(width: savedItemSize + 12, height: savedItemSize + 12)
                    .foregroundColor(Color(hex: "#909090"))
            )
            .padding(.bottom, 10)
            Text(album.name)
                .font(.custom(GothamBold, size: 14))
                .foregroundColor(Color(hex: "#2E313C"))
                .padding(.bottom, 10)
            
        }
        .padding(.bottom, 10)
    }
}
