//
//  AlbumOverview.swift
//  Scrollo
//
//  Created by Artem Strelnik on 08.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct AlbumOverview: View {
    @Binding var isPresent: Bool
    
    var album: AlbumModel?
    
    @StateObject var savedPostsViewModel: SavedPostsViewModel = SavedPostsViewModel()
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    withAnimation(.easeInOut){
                        isPresent.toggle()
                    }
                }) {
                    Image("circle.left.arrow.black")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("\(album!.name)")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                    
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#4F4F4F"))
                        .rotationEffect(Angle(degrees: 90))
                }
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom)
            
            if savedPostsViewModel.savedMediaPostsLoad {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        PostCompositionView(posts: $savedPostsViewModel.savedMediaPosts)
                    }
                }
            }
            else{
                Spacer(minLength: 0)
                ProgressView()
            }
           
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            savedPostsViewModel.getSavedMediaPosts(albumId: album!.id)
        })
    }
}
