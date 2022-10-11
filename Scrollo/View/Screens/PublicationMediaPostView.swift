//
//  PublicationMediaPostView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI
import Photos
import UIKit

struct PublicationMediaPostView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var mediaPost: AddMediaPostViewModel = AddMediaPostViewModel()
    @State var present: MediaType = .gallery
    @State private var isPresentCamera: Bool = false
    @State private var isPresentVideoCamera: Bool = false
    
    @State private var isPresentAddMediaPost: Bool = false
    @State var presentationSelectFromAlboum: Bool = false
    
    var body: some View {
        
        VStack {
            
            //MARK: Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle_close")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                Button(action: {
                    presentationSelectFromAlboum.toggle()
                }) {
                    HStack {
                        Text("недавние")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .foregroundColor(Color(hex: "#2E313C"))
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                            .font(.title3)
                    }
                }
                Spacer(minLength: 0)
                Button(action: {
                    withAnimation {
                        isPresentAddMediaPost.toggle()
                    }
                }) {
                    Image("circle.right.arrow")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
            }
            .padding(.horizontal)
//            .padding(.vertical)
            .background(Color.white)
            .zIndex(1)
            //MARK: List media
            if mediaPost.loadImages {
                if let selection = mediaPost.selection {
                    SelectedPostImageView(multiply: $mediaPost.multiply, pickedPhoto: $mediaPost.pickedPhoto, selection: $mediaPost.selection)
                    ScrollView(showsIndicators: false) {

                        ForEach(0..<mediaPost.allPhotos.count, id: \.self) {index in
                            HStack(spacing: 4) {
                                ForEach(0..<mediaPost.allPhotos[index].count, id: \.self) {key in
                                    Button(action: {
                                        //MARK: If pick multiply photo
                                        if mediaPost.multiply  {


                                            if let index = mediaPost.pickedPhoto.firstIndex(where: {$0.id == mediaPost.allPhotos[index][key].id}) {

                                                if mediaPost.pickedPhoto.count > 1 {

                                                    mediaPost.pickedPhoto.remove(at: index)
                                                    mediaPost.selection! = mediaPost.pickedPhoto[mediaPost.pickedPhoto.count - 1]
                                                }
                                            } else {
                                                mediaPost.selection! = mediaPost.allPhotos[index][key]

                                                if mediaPost.pickedPhoto.count < 5 {

                                                    mediaPost.pickedPhoto.append(mediaPost.allPhotos[index][key])
                                                }
                                            }
                                        } else {
                                            //MARK: If pick one photo
                                            if mediaPost.allPhotos[index][key].id != selection.id {

                                                mediaPost.selection! = mediaPost.allPhotos[index][key]
                                            }
                                            mediaPost.pickedPhoto = [mediaPost.allPhotos[index][key]]
                                        }
                                    }) {
                                        ThumbnailView(pickedPhoto: $mediaPost.pickedPhoto, photo: mediaPost.allPhotos[index][key], multiply: mediaPost.multiply, selection: selection)
                                    }
                                }
                            }
                        }
                        Color.clear.frame(height: 100)
                    }
                }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
            
        }
        .overlay(
            HStack {
                BottomBarButton(title: "галерея", presentation: MediaType.gallery, action: {})
                BottomBarButton(title: "фото", presentation: MediaType.photo, action: {
                    self.isPresentCamera = true
                })
                BottomBarButton(title: "видео", presentation: MediaType.video, action: {
                    isPresentVideoCamera.toggle()
                })
            }
            .padding(.top ,16)
            .frame(width: UIScreen.main.bounds.width, height: 96,alignment: Alignment(horizontal: .center, vertical: .top))
            .background(Color(hex: "#1F2128"))
            .clipShape(CustomCorner(radius: 18, corners: [.topLeft, .topRight])),
            alignment: Alignment(horizontal: .center, vertical: .bottom)
        )
        .ignoresSafeArea(.all, edges: .bottom)
        //MARK: Add content & published
        .navigationView(isPresent: $isPresentAddMediaPost, content: {
            AddMediaPostView(isPresent: $isPresentAddMediaPost).ignoreDefaultHeaderBar.environmentObject(mediaPost)
        })
        .onAppear(perform: mediaPost.permissions)
        .fullScreenCover(isPresented: self.$presentationSelectFromAlboum, content: {
            ImagePickerView(sourceType: .savedPhotosAlbum) { image in
                mediaPost.pickedPhoto = [Asset(asset: PHAsset(), image: image, withUIImage: true)]
                isPresentAddMediaPost = true
            }
            .edgesIgnoringSafeArea(.all)
            .onDisappear {
                self.present = .gallery
            }
        })
        .fullScreenCover(isPresented: self.$isPresentVideoCamera, content: {
            CameraView(isPresentAddMediaPost: $isPresentAddMediaPost)
                .environmentObject(mediaPost)
        })
        .fullScreenCover(isPresented: self.$isPresentCamera, content: {
            ImagePickerView(sourceType: .camera) { image in

                mediaPost.pickedPhoto = [Asset(asset: PHAsset(), image: image, withUIImage: true)]
                isPresentAddMediaPost = true
            }
            .edgesIgnoringSafeArea(.all)
            .onDisappear {
                self.present = .gallery
            }
        })
    }
    
    @ViewBuilder
    private func BottomBarButton (title: String, presentation: MediaType, action: @escaping () -> Void) -> some View {
        
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.system(size: 18))
                .fontWeight(self.present == presentation ? .bold : .none)
                .textCase(.uppercase)
                .foregroundColor(self.present == presentation ? Color(hex: "#5B86E5") : Color(hex: "#828796"))
        }
        .frame(width: (UIScreen.main.bounds.width / 3) - 23)
    }
}

struct CameraView : View {
    @Environment(\.presentationMode) var present: Binding<PresentationMode>
    @EnvironmentObject var mediaPost: AddMediaPostViewModel
    @StateObject var cameraController: CameraController = CameraController()
    @State var playAnimated: Bool = false
    @Binding var isPresentAddMediaPost: Bool
    
    var body : some View {
        
        ZStack(alignment: .topLeading) {
            
            GeometryReader {proxy in
                
                let size = proxy.size
                
                CameraPreview(size: size)
                    .environmentObject(cameraController )
            }
            //MARK: Camera controll
            .overlay(
                HStack{
                    Button(action: {
                        if cameraController.isRecording {

                            cameraController.stopRecording()

                            withAnimation(.spring()) {
                                playAnimated = false
                            }
                        } else {

                            cameraController.startRecording()

                            withAnimation(.spring()) {
                                playAnimated = true
                            }
                        }

                    }) {
                        ZStack {
                            Circle()
                                .strokeBorder(LinearGradient(gradient: Gradient(colors: [
                                    playAnimated ? Color(hex: "#36DCD8") : Color(hex: "#FFFFFF"),
                                    playAnimated ? Color(hex: "#5B86E5") : Color(hex: "#FFFFFF")
                                    ]), startPoint: .leading, endPoint: .topTrailing),lineWidth: 9)
                                .background(Circle().frame(width: playAnimated ? 40 : 70, height: playAnimated ? 40 : 70).foregroundColor(Color.white))
                                .frame(width: playAnimated ? 100 : 70, height: playAnimated ? 100 : 70)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(playAnimated ? Color(hex: "#36DCD8") : Color.white)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .buttonStyle(FlatLinkStyle())
                }
                    .offset(y: -90)
                ,alignment: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            //MARK: Back button
            Button(action: {
                mediaPost.pickedPhoto = [mediaPost.allPhotos[0][0]]
                mediaPost.selection = mediaPost.allPhotos[0][0]
                present.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: 60)
            .offset(x: 5)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear(perform: cameraController.permission)
        .onReceive(cameraController.$didFinishRecordingTo, perform: { (finish) in
            if finish {
                if let url = cameraController.previewURL, let thumbnail = cameraController.thumbnail {
                    
                    mediaPost.pickedPhoto = [Asset(asset: PHAsset(), image: thumbnail, withAVCamera: url)]
                    
                    cameraController.thumbnail = nil
                    cameraController.previewURL = nil
                    cameraController.didFinishRecordingTo = false
                    
                    isPresentAddMediaPost.toggle()
                    present.wrappedValue.dismiss()
                }
            }
        })
//        .alert(isPresented: $cameraController.alert.show) {
//            Alert(title: Text(cameraController.alert.title), message: Text(cameraController.alert.message), dismissButton: .default(Text("Продолжить")))
//        }
        
    }
    
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
      var path = Path()
      
      path.move(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
      
      path.closeSubpath()
      
      return path
    }
  }


class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    var complited: (UIImage) -> Void
    
    init(picker: ImagePickerView, complited: @escaping (UIImage) -> Void) {
        self.picker = picker
        self.complited = complited
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.complited(selectedImage)
        self.picker.isPresented.wrappedValue.dismiss()
        
    }
    
}


struct ImagePickerView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
    var complited: (UIImage) -> Void
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self, complited: self.complited)
    }
}

enum MediaType {
    case gallery, photo, video
}

private struct ThumbnailView: View {
    @Binding var pickedPhoto: [Asset]
    var photo: Asset
    let multiply: Bool
    let selection: Asset
    let size = (UIScreen.main.bounds.width / 3) - 8
    
    var body: some View{
        
        ZStack(alignment: .bottomTrailing) {
            
            ZStack(alignment: .topTrailing) {
                
                Image(uiImage: photo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .cornerRadius(10)
                    .overlay(
                        Color.white.opacity(selection.id == photo.id ? 0.4 : 0)
                    )
                if multiply {
                    
                    ZStack {
                        
                        let number = self.getNumber()
                        
                        Circle()
                            .strokeBorder(Color.white,lineWidth: 1)
                            .background(Circle().foregroundColor(self.checkSelect() ? Color(hex: "#66b0ff") : Color.white.opacity(0.3)))
                            .frame(width: 20, height: 20)
                        
                        if number != -1 {
                            
                            Text("\(number)")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 20, height: 20)
                    .offset(x: -8, y: 8)
                }
            }
            if photo.asset.mediaType == .video {
                
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(8)
            }
        }
    }
    
    func getNumber () -> Int {
        
        if let index = pickedPhoto.firstIndex(where: { $0.id == photo.id}) {
            
            return index + 1
        } else {
            
            return -1
        }
    }
    func checkSelect () -> Bool {
        
        if let _ = pickedPhoto.firstIndex(where: { $0.id == photo.id}) {
            
            return true
        } else {
            
            return false
        }
    }
}

private struct SelectedPostImageView: View {
    @Binding var multiply: Bool
    @Binding var pickedPhoto: [Asset]
    @Binding var selection: Asset?
    @State var help: Bool? = nil
    
    var body : some View{
        
        ZStack(alignment: .bottomTrailing) {
            
            Image(uiImage: selection?.image ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: 300)
                .clipped()
            
            Button(action: {
                
                if multiply {
                    
                    if let last = pickedPhoto.last {
                        
                        selection = last
                        pickedPhoto = [last]
                    }
                    
                    multiply = false
                } else {
                    
                    multiply = true
                }
            }) {
                
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(multiply ? Color(hex: "#66b0ff").opacity(0.7) : Color(hex: "#1F2128").opacity(0.7))
            .cornerRadius(16)
            .offset(x: -18, y: -21)
            .overlay(
                VStack(spacing: 0) {
                    Text("Вы можете разместить до 5 фото и видео в одной публикации.")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background(Color(hex: "#282828"))
                .cornerRadius(7)
                    .frame(width: 280, height: 70)
                .overlay(
                    Triangle()
                        .fill(Color(hex: "#282828"))
                        .frame(width: 15, height: 8, alignment: .center)
                        .rotationEffect(.init(degrees: 180))
                        .offset(x: -20, y: -5),
                    alignment: Alignment(horizontal: .trailing, vertical: .bottom)
                ).offset(x: -5, y: -65).opacity(self.help == true ? 1 : 0),
                alignment: .trailing
            )
        }
        .frame(height: 300)
        .onAppear {
            
            if self.help == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.default) {
                        self.help = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.default) {
                            self.help = false
                        }
                    }
                }
            }
        }
    }
}

struct AddMediaPostView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var mediaPost: AddMediaPostViewModel
    @Binding var isPresent: Bool
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Button(action: {
                    if !mediaPost.isPublished {
                        isPresent.toggle()
                        mediaPost.pickedPhoto = [mediaPost.allPhotos[0][0]]
                        mediaPost.selection = mediaPost.allPhotos[0][0]
                        mediaPost.content = ""
                    }
                }) {
                    Image("circle_close")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                Text("Публикация")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#2E313C"))
                Spacer(minLength: 0)
                Button(action: {
                    mediaPost.publish { post in
//                        guard let post = post else {return}
                        
                        isPresent.toggle()
                        mediaPost.pickedPhoto = [mediaPost.allPhotos[0][0]]
                        mediaPost.selection = mediaPost.allPhotos[0][0]
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    if mediaPost.isPublished {
                        ProgressView()
                    } else {
                        Image("circle.right.arrow")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 14)
            
            
            VStack(spacing: 0) {
                
                TabView {
                    ForEach(0..<mediaPost.pickedPhoto.count, id: \.self) {index in
                        Image(uiImage: mediaPost.pickedPhoto[index].image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                            .background(Color.black)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("отметить людей")
                        .foregroundColor(Color(hex: "#828796"))
                    Spacer(minLength: 0)
                    Text(">")
                        .foregroundColor(Color(hex: "#828796"))
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 20)
                HStack(spacing: 0) {
                    Text("добавить место")
                        .foregroundColor(Color(hex: "#828796"))
                    Spacer(minLength: 0)
                    Text(">")
                        .foregroundColor(Color(hex: "#828796"))
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 20)
            }
            .background(Color(hex: "#1F2128"))
            
            TextEditor(text: $mediaPost.content)
                .padding()
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
    }
}
