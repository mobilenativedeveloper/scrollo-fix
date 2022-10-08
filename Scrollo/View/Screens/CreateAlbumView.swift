//
//  CreateAlbumView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 08.10.2022.
//

import SwiftUI

struct CreateAlbumView: View {
    @EnvironmentObject var albumsViewModel: AlbumsViewModel
    
    @Binding var isPresent: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation{
                        isPresent.toggle()
                    }
                }) {
                    Image("circle.xmark.black")
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
                    albumsViewModel.createAlbum { newAlbum in
                        if albumsViewModel.albumsComposition[albumsViewModel.albumsComposition.count - 1].count < 3{
                            albumsViewModel.albumsComposition[albumsViewModel.albumsComposition.count - 1].append(newAlbum)
                            withAnimation{
                                isPresent.toggle()
                            }
                        }
                        else{
                            albumsViewModel.albumsComposition.append([newAlbum])
                            withAnimation{
                                isPresent.toggle()
                            }
                        }
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
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    Text("Название")
                        .fontWeight(.bold)
                    TextField("Название альбома", text: $albumsViewModel.name)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
