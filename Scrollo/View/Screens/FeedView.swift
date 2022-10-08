//
//  Feed.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FrendModel: Identifiable {
    var id = UUID().uuidString
    var image: String
    var login: String
    var career: String
    var posts: [String]
    var subtitle: String
}

struct FeedView: View {
    @StateObject var storyData: StoryViewModel = StoryViewModel()
    @StateObject var postViewModel: PostViewModel = PostViewModel()
    
    @State var loadPosts: Bool = false
    
    @State var refreshing: Bool = false
    
    @Binding var offset: CGFloat
    
    @State var endFeed: Bool = false
    
    @State var profilePresent: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("logo_large")
                    .resizable()
                    .frame(width: 95, height: 21)
                Spacer()
                Button(action: {
                    offset = screen_rect.width
                }){
                    Image("messanger")
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                }
            }
            .padding(.horizontal)
            .background(Color(hex: "#F9F9F9"))
            
            VStack{
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 0) {
                        StoriesUserListItem()
                            .padding(.leading)
                        
                        ForEach(0..<storyData.stories.count){index in
                            StoriesListItem(story: storyData.stories[index])
                                .padding(.leading, 10)
                        }
                    }
                }
                if self.loadPosts{
                    if postViewModel.posts.count > 0{
                        ForEach(0..<postViewModel.posts.count, id: \.self){index in
                            PostView(post: $postViewModel.posts[index])
                                .environmentObject(postViewModel)
                            
                            if index % 2 == 0 {
                                ProbablyFamiliarView()
                            }
                            
                            if index == postViewModel.posts.count - 1{
                                LazyVStack{
                                if self.endFeed{
                                    VStack(alignment: .center, spacing: 0) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 21))
                                            .gradientForeground(colors: [Color(hex: "#5B86E5"), Color(hex: "#36DCD8")])
                                            .padding()
                                            .background(
                                                Circle()
                                                    .strokeBorder(
                                                            AngularGradient(gradient: Gradient(colors: [Color(hex: "#5B86E5"), Color(hex: "#36DCD8")]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                                                            lineWidth: 2
                                                        )
                                            )
                                            .padding(.bottom)
                                            .scaleEffect(endFeed ? 1 : 0)
                                        Text("Вы посмотрели все обновления")
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.black)
                                            .padding(.bottom, 5)
                                        Text("Вы посмотрели все новые публикации за последние 7д.")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            .padding(.horizontal, 40)
                                    }
                                    .padding(.vertical)
                                    .transition(.opacity)
                                }
                                
                                Color.clear.frame(height: 200)
                                    .onAppear {
                                        if !self.endFeed{
                                            withAnimation(.easeInOut(duration: 0.2)){
                                                self.endFeed = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        EmptyFeed()
                            .padding(.top, 20)
                            .transition(.opacity)
                    }
                }
                else{
                    ProgressView()
                }
            }
            .background(Color(hex: "#F9F9F9"))
            .pullToRefresh(refreshing: $refreshing, backgroundColor: Color(hex: "#F9F9F9")) { done in
                
                postViewModel.getPostsFeed{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        self.endFeed = false
                        done()
                    }
                }
            }
        }
        .background(Color(hex: "#F9F9F9"))
        .onAppear {
            if !self.loadPosts{
                postViewModel.getPostsFeed {
                    self.loadPosts = true
                }
            }
            
        }
    }
}

private struct RecommendationCard: View{
    var account: FrendModel
    var proxy: GeometryProxy
    var body: some View{
        VStack{
            Image(account.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            
            Text(account.login)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .fontWeight(.bold)
            Text(account.career)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            HStack(spacing: 1){
                ForEach(0..<account.posts.count, id: \.self){index in
                    WebImage(url: URL(string: account.posts[index])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                        .clipped()
                }
            }
            .padding(.horizontal, 5)
            
            Text(account.subtitle)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.vertical, 7)
            
            Button(action:{}){
                Text("Подписаться")
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "#5B86E5"))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.1), radius: 15, x: 0, y: 0)
        )
        .padding(.vertical)
        .frame(width: proxy.size.width)
    }
}

private struct EmptyFeed: View{
    @State var currentIndex: Int = 0
    let data: [FrendModel] = [
        FrendModel(image: "natgeo_logo", login: "natgeo", career: "National Geographic", posts: [
            "https://picsum.photos/200/300?random=1",
            "https://picsum.photos/200/300?random=2",
            "https://picsum.photos/200/300?random=3",
        ], subtitle: "Популярное"),
        FrendModel(image: "nasa_logo", login: "nasa", career: "NASA", posts: [
            "https://picsum.photos/200/300?random=4",
            "https://picsum.photos/200/300?random=5",
            "https://picsum.photos/200/300?random=6",
        ], subtitle: "Популярное"),
        FrendModel(image: "marga_owski", login: "marga_owski", career: "Margarete Stokowski", posts: [
            "https://picsum.photos/200/300?random=7",
            "https://picsum.photos/200/300?random=8",
            "https://picsum.photos/200/300?random=9",
        ], subtitle: "Рекомендации Scrollo"),
        FrendModel(image: "natgeo_logo", login: "natgeo", career: "National Geographic", posts: [
            "https://picsum.photos/200/300?random=10",
            "https://picsum.photos/200/300?random=11",
            "https://picsum.photos/200/300?random=12",
        ], subtitle: "Популярное"),
        FrendModel(image: "marga_owski", login: "marga_owski", career: "Margarete Stokowski", posts: [
            "https://picsum.photos/200/300?random=13",
            "https://picsum.photos/200/300?random=14",
            "https://picsum.photos/200/300?random=15",
        ], subtitle: "Рекомендации Scrollo"),
        FrendModel(image: "nasa_logo", login: "nasa", career: "NASA", posts: [
            "https://picsum.photos/200/300?random=16",
            "https://picsum.photos/200/300?random=17",
            "https://picsum.photos/200/300?random=18",
        ], subtitle: "Популярное"),
    ]
    var body: some View{
        VStack(alignment: .center, spacing: 0) {
            Text("Добро пожаловать в Scrollo!")
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .padding(.bottom, 5)
            Text("Здесь будут показываться фото и видео людей, на которых вы подпишитесь.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 40)
            
            SnapCarousel(spacing: 0, trailingSpace: 160, index: $currentIndex, items: data) {account in
                GeometryReader{proxy in
                    RecommendationCard(account: account, proxy: proxy)
                }
            }
            .padding(.top)
        }
    }
}

private struct ProbablyFamiliarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Возможно вам знакомы")
                .font(.custom(GothamBold, size: 12))
                .foregroundColor(.black)
                .padding(.top, 18)
                .padding(.bottom, 8)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self){index in
                        ProbablyFamiliarItem(photo: "story1", username: "Андрей Булкин", login: "@Andy_bakkery")
                            .padding(.trailing, index == 6 ? 0 : 19)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func ProbablyFamiliarItem(photo: String, username: String, login: String) -> some View {
        VStack(spacing: 0) {
            Image(photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 94, height: 91)
                .cornerRadius(15)
                .padding(.horizontal, 4)
                .padding(.top, 5)
                .padding(.bottom, 6)
            Text(username)
                .font(.custom(GothamBold, size: 8))
                .foregroundColor(.black)
                .padding(.bottom, 3)
            Text(login)
                .font(.custom(GothamBook, size: 7))
                .foregroundColor(Color(hex: "#919191"))
                .padding(.bottom, 9)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color(hex: "#040404").opacity(0.1), radius: 4, x: 0, y: 0)
    }
}
