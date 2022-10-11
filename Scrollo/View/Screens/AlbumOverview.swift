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
    
    @Binding var album: AlbumModel?
    
    var onRemove: ()->()
    
    @StateObject var savedPostsViewModel: SavedPostsViewModel = SavedPostsViewModel()
    
    @State var deleteAlbum: Bool = false
    
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
                    deleteAlbum.toggle()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#f25b6e"))
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            else{
                Spacer(minLength: 0)
                ProgressView()
            }
           
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .alert(isPresented: self.$deleteAlbum) {
            Alert(title: Text("Вы действительно хотите удалить альбом?"), message: nil, primaryButton: .destructive(Text("Удалить")){
                
                savedPostsViewModel.removeAlbum(albumId: album!.id) {
                    onRemove()
                }
            }, secondaryButton: .default(Text("Отменить")))
        }
        .onAppear(perform: {
            savedPostsViewModel.getSavedMediaPosts(albumId: album!.id)
        })
    }
}
