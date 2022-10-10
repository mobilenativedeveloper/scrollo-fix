//
//  ImageOverviewView.swift
//  scrollo
//
//  Created by Artem Strelnik on 16.09.2022.
//

import SwiftUI

struct ImageOverviewView: View {
    @Binding var loadExpandedContent: Bool
    @Binding var isExpanded: Bool
    @Binding var expandedMedia: MessageModel?
    var animation: Namespace.ID
    @Binding var offset: CGSize
    var offsetProgress: CGFloat
    
    @State var isShare: Bool = false
    
    var body: some View {
        if let expandedMedia = self.expandedMedia{
            VStack{
                GeometryReader{proxy in
                    let size = proxy.size
                    if let thumbnail = expandedMedia.asset?.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .cornerRadius(loadExpandedContent ? 0 : 10)
                            .offset(y: loadExpandedContent ? offset.height : .zero)
                            .gesture(
                                DragGesture()
                                    .onChanged({ value in
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            offset = value.translation
                                        }

                                    })
                                    .onEnded({ value in
                                        let height = value.translation.height
                                        if height > 0 && height > 100{
                                            withAnimation(.easeInOut(duration: 0.2)){
                                                loadExpandedContent = false
                                            }
                                            withAnimation(.easeInOut(duration: 0.2).delay(0.05)){
                                                isExpanded = false
                                                self.expandedMedia = nil
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                offset = .zero
                                            }
                                        }
                                        else{
                                            withAnimation(.easeInOut(duration: 0.2)){
                                                offset = .zero
                                            }
                                        }
                                    })
                            )
                    }
                }
                .matchedGeometryEffect(id: expandedMedia.id, in: animation)
                .frame(height: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top, content:{
                HStack(spacing: 10){
                    Spacer(minLength: 10)
                    
                    Button(action: {
                        isShare.toggle()
                    }){
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            loadExpandedContent = false
                        }
                        withAnimation(.easeInOut(duration: 0.2).delay(0.05)){
                            isExpanded = false
                            self.expandedMedia = nil
                        }
                    }){
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 10)
                }
                .padding()
                .opacity(loadExpandedContent ? 1 : 0)
                .opacity(offsetProgress)
            })
            .actionSheet(isPresented: $isShare, content: {
                ActionSheet(title: Text("Поделиться"), buttons: [
                    .default(Text("Cохранить в Фотопленку")) {
                        saveToGallery()
                    },
                    .cancel(Text("Отмена"))
                ])
            })
            .transition(.offset(x: 0, y: 1))
            .onAppear{
                withAnimation(.easeInOut(duration: 0.2)){
                    loadExpandedContent = true
                }
            }
        }
        
    }

    func saveToGallery(){
        guard let inputImage = expandedMedia?.asset?.thumbnail else { return }

        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: inputImage)
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

