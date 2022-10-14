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
    @StateObject var postViewModel: PostViewModel = PostViewModel()
    
    @State var loadPosts: Bool = false
    
    @State var refreshing: Bool = false
    
    @Binding var showMessanger: Bool
    
    @State var endFeed: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0){
            
            FeedHeader(showMessanger: $showMessanger)
            VStack(spacing: 0) {
                
                
                
                
                ScrollView{
                    VStack{
                        FeedStoryList()
                        FeedPosts(loadPosts: self.loadPosts, endFeed: self.$endFeed)
                            .environmentObject(postViewModel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }   
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .pullToRefresh(refreshing: $refreshing, backgroundColor: Color(hex: "#F9F9F9")) { done in
                postViewModel.getPostsFeed{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        self.endFeed = false
                        done()
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, edges?.top ?? 15)
        .background(Color(hex: "#F9F9F9").edgesIgnoringSafeArea(.all))
        .onAppear {
            if !self.loadPosts{
                postViewModel.getPostsFeed {
                    self.loadPosts = true
                }
            }
        }
    }
}
