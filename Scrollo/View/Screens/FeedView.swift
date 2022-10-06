//
//  Feed.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI

struct FeedView: View {
    @StateObject var storyData: StoryViewModel = StoryViewModel()
    @StateObject var postViewModel: PostViewModel = PostViewModel()
    
    @State var loadPosts: Bool = false
    
    @State var refreshing: Bool = false
    
    @Binding var offset: CGFloat
    
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
                        }
                    }
                    else{
                        VStack(alignment: .center) {
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
                        }
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
