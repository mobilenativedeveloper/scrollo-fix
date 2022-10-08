//
//  SavedView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct SavedView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var postViewModel: PostViewModel
    
    @StateObject var savedPostsViewModel: SavedPostsViewModel = SavedPostsViewModel()
    
    @State private var currentTab: String = "media"
    @Namespace var animation
    let savedItemSize: CGFloat = (screen_rect.width / 2) - 26 - 9
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle_close")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("сохранённое")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                   
                }) {
                    
                    Image("blue.circle.outline.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            HStack(spacing: 0) {
                TabButton(title: "Медиа", currentTab: $currentTab, animation: animation, id: "media")
                TabButton(title: "Посты", currentTab: $currentTab, animation: animation, id: "text")
            }
            .padding(.horizontal)
            
            ScrollView{
                if currentTab == "media"{
                    
                }
                if currentTab == "text"{
                    if savedPostsViewModel.savedTextPostsLoad{
                        ForEach(0..<savedPostsViewModel.savedTextPosts.count, id: \.self){index in
                            PostView(post: $savedPostsViewModel.savedTextPosts[index])
                                .environmentObject(postViewModel)
                        }
                    }
                    else{
                        ProgressView()
                    }
                }
                Spacer(minLength: 0)
            }
            .animation(.none, value: currentTab)
            
            
        }
        .onAppear {
            savedPostsViewModel.getSavedTextPosts()
        }
    }
    
}
