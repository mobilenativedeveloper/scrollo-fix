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
    
    @StateObject var savedPosts: SavedPostsViewModel = SavedPostsViewModel()
    @StateObject var albumsViewModel: AlbumsViewModel = AlbumsViewModel(composition: true)
    
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
            
            VStack{
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<albumsViewModel.albumsComposition.count, id: \.self){index in
                            ForEach(0..<albumsViewModel.albumsComposition[index].count, id: \.self) {_ in

                                HStack(spacing: 0) {
                                    if albumsViewModel.albumsComposition[index].count >= 1 {
                                        SavedItem(album: albumsViewModel.albumsComposition[index][0])
                                    }
                                    Spacer(minLength: 0)
                                    if albumsViewModel.albumsComposition[index].count == 2 {
                                        SavedItem(album: albumsViewModel.albumsComposition[index][1])
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 10)
                }
                .opacity(currentTab == "media" ? 1 : 0)
                
                ScrollView {
                    ForEach(0..<savedPosts.savedTextPosts.count, id: \.self) {index in
                        PostView(post: $savedPosts.savedTextPosts[index])
                            .environmentObject(postViewModel)
                    }
                }
                .opacity(currentTab == "text" ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder
    private func SavedItem(album: AlbumModel) -> some View {
        NavigationLink(destination: Text("SavedMediaAlbumView")) {
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
}

private struct AddAlbumView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @EnvironmentObject var addAlbumController: AddAlbumViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
//                    if addAlbumController.status != .load {
//                        presentationMode.wrappedValue.dismiss()
//                    }
                }) {
                    Image("circle_close")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("Новый альбом")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
//                    if addAlbumController.status != .load {
//                        addAlbumController.createAlboum()
//                    }
                }) {
//                    if addAlbumController.status == .load {
//                        ProgressView()
//                            .frame(width: 24, height: 24)
//                    } else {
//                        Image("blue_circle_outline_plus")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 24, height: 24)
//                    }
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            ScrollView(showsIndicators: false) {
                HStack(spacing: 0) {
                    Text("Название")
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Spacer()
                }
//                TextField("Название альбома", text: $addAlbumController.name)
//                    .padding(.horizontal)
            }
        }
//        .alert(isPresented: $addAlbumController.alert.show) {
//            Alert(
//                title: Text(addAlbumController.alert.title),
//                message: Text(addAlbumController.alert.message),
//                dismissButton: .default(Text("Продолжить"), action: {
//                    if addAlbumController.status == .success {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                })
//            )
//        }
    }
}
