//
//  FeedPosts.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct FeedPosts: View {
    
    @EnvironmentObject var postViewModel: PostViewModel
    
    var loadPosts: Bool
    
    @Binding var endFeed: Bool
    
    var body: some View {
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
                        if endFeed{
                            EndFeedView(endFeed: endFeed)
                        }
                        
                        Color.clear.frame(height: 200)
                            .onAppear {
                                if !self.endFeed{
                                    withAnimation(.easeInOut(duration: 0.2)){
                                        endFeed = true
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
}
