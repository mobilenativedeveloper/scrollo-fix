//
//  PublicationStoryView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 04.10.2022.
//

import SwiftUI
import Photos

struct PublicationStoryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var galleryImagesViewModel: GalleryImagesViewModel = GalleryImagesViewModel()
    @State var mediaAlbum: Bool = false
    private let columns = 3
    private let size = (UIScreen.main.bounds.width / 3) - 12
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle.xmark.white")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                Text("добавить историю")
                    .font(.custom(GothamBold, size: 20))
                    .foregroundColor(.white)
                Spacer(minLength: 0)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle.right.arrow.white")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
            }
            .padding(.horizontal, 23)
            .background(Color(hex: "#1F2128"))
            
            
            
            if galleryImagesViewModel.loadAssets {
                PreviewStoryView(mediaAlbum: $mediaAlbum)
                    .environmentObject(galleryImagesViewModel)
                ScrollView(showsIndicators: false) {
                    makeGrid()
                }
                Spacer()
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            galleryImagesViewModel.loadMedia(onlyPhoto: false)
        }
    }
    
    private func makeGrid() -> some View {
        let count = galleryImagesViewModel.assets.count
        let rows = count / columns + (count % columns == 0 ? 0 : 1)
            
        return VStack(alignment: .leading, spacing: 9) {
            ForEach(0..<rows) { row in
                HStack(spacing: 9) {
                    ForEach(0..<self.columns) {column in
                        let index = row * self.columns + column
                        if index < count {
                            GridThumbnailGallery(asset: galleryImagesViewModel.assets[index], size: size)
                                .environmentObject(galleryImagesViewModel)
                        } else {
                            AnyView(EmptyView())
                                .frame(width: size, height: 180)
                        }
                    }
                }
            }
        }
        .padding(.top, 10)
    }
}

private struct GridThumbnailGallery : View {
    @EnvironmentObject var galleryImagesViewModel: GalleryImagesViewModel
    var asset: AssetModel
    var size: CGFloat
    var body : some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: asset.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: 180)
                    .cornerRadius(8)
                    .clipped()
                if asset.asset.mediaType == .video {
                    Text(galleryImagesViewModel.getVideoDuration(asset: asset))
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .offset(x: 6, y: -9)
                }
            }
        }
    }
}

private struct PreviewStoryView : View {
    @EnvironmentObject var galleryImagesViewModel: GalleryImagesViewModel
    @Binding var mediaAlbum: Bool
    var body : some View {
        
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .center) {
                
                Color(hex: "#1F2128")
                
                Image("add.story.placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 188, height: 188)
                    .offset(y: -25)
                
                
            }
            .frame(height: UIScreen.main.bounds.height / 3)
            
            HStack(spacing: 0) {
                PreviewStoryAlbumPickerView()
                    .offset(x: 10, y: -10)
                    .environmentObject(galleryImagesViewModel)
                Spacer()
                HStack {

                    Image("group")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .aspectRatio(contentMode: .fit)
                    Text("выбрать несколько")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                .background(Color(hex: "#1F2128").opacity(0.7))
                .cornerRadius(16)
                .offset(x: -10, y: -10)
            }
        }
    }
}

private struct PreviewStoryAlbumPickerView : View {
    @EnvironmentObject var galleryImagesViewModel: GalleryImagesViewModel
    @State var cameraPresentation: Bool = false
    
    var body : some View {
        
        Menu {
            Button(action: {
                cameraPresentation.toggle()
            }) {
                HStack {
                    Text("Открыть камеру")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .colorMultiply(.white)
                        .textCase(.uppercase)
                        .padding(.vertical, 15)
                    Image(systemName: "camera")
                }
            }
            ForEach(0..<galleryImagesViewModel.albums.count, id: \.self) {index in
                if let album = galleryImagesViewModel.albums[index] {
                    Button(action: {
                        withAnimation(.none) {
                            galleryImagesViewModel.selectedAlbum = index
                        }
                    }) {
                        HStack {
                            if galleryImagesViewModel.selectedAlbum == index {
                                Image(systemName: "checkmark")
                            }
                            Text("\(galleryImagesViewModel.getAlbumTitle(album: album))")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .colorMultiply(.white)
                                .textCase(.uppercase)
                                .padding(.vertical, 15)
                        }
                    }
                }
            }
        } label: {
            Text(galleryImagesViewModel.getAlbumTitle(album: galleryImagesViewModel.albums[galleryImagesViewModel.selectedAlbum]))
                    .foregroundColor(Color.white)
            Image(systemName: "chevron.down")
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .onChange(of: galleryImagesViewModel.selectedAlbum) { _ in
            galleryImagesViewModel.getThumbnailAssetsFromAlbum(onlyPhoto: false)
        }
        .fullScreenCover(isPresented: $cameraPresentation) {
            
        } content: {
            StoryCamera()
        }
    }
    
}

private struct StoryCamera : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var cameraController: CameraController = CameraController()
    @State var selectedMode: Int = 0
    let modes: [String] = ["Type", "Live", "Normal", "Boomerang", "Superzoom"]
    
    var body : some View {
        
        ZStack(alignment: .topLeading) {
            
            VStack(spacing: 0) {
                
                GeometryReader {proxy in
                    
                    let size = proxy.size
                    
                    CameraPreview(size: size)
                        .environmentObject(cameraController)
                }
                .overlay(
                    HStack(spacing: 0) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("circle.xmark.white")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .aspectRatio(contentMode: .fill)
                                
                        }
                        .padding(.trailing, 32)
                        Button(action: {}) {
                            Image("flash")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .padding(.trailing, 32)
                        Button(action: {}) {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        .padding(.trailing, 32)
                        Button(action: {
                            cameraController.flip()
                        }) {
                            Image("flip.camera")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .padding(.trailing, 32)
                        Button(action: {}) {
                            Image("masks")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                        .offset(y: -30)
                    ,alignment: .bottom
                )
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 34) {
                            Color.clear
                                .frame(width: (UIScreen.main.bounds.size.width - 70) / 2.0)
                            ForEach(0..<modes.count, id: \.self) { index in
                                Text(modes[index])
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .textCase(.uppercase)
                                    .foregroundColor(selectedMode == index ? .white : .white.opacity(0.7))
                                    .onTapGesture {
                                        withAnimation {
                                            scrollProxy.scrollTo(index, anchor: .center)
                                            selectedMode = index
                                        }
                                    }
                                    .id(index)
                            }
                            Color.clear
                                .frame(width: (UIScreen.main.bounds.size.width - 70) / 2.0)
                        }
//                        .introspectScrollView(customize: { scrollView in
//                            scrollView.addGestureRecognizer(UIPanGestureRecognizer()) // disable scrollView scroll
//                        })
                    }
                }
                .frame(height: 79)
                .background(Color(hex: "#1F2128"))
            }
        }
        .background(Color(hex: "#1F2128").edgesIgnoringSafeArea(.all))
        .onAppear(perform: cameraController.permission)
//        .alert(isPresented: $cameraController.alert.show) {
//            Alert(title: Text(cameraController.alert.title), message: Text(cameraController.alert.message), dismissButton: .default(Text("Продолжить")))
//        }
    }
}
