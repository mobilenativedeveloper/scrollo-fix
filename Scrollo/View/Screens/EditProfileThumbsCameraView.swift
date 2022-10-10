//
//  EditProfileThumbsCameraView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI

struct EditProfileThumbsCameraView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var cameraController: CameraController = CameraController()
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle.xmark.black")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                Text("Фото")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#2E313C"))
                Spacer(minLength: 0)
                Button(action: {
                    
                }) {
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal)
            
            GeometryReader {proxy in
                
                let size = proxy.size
                
                CameraPreview(size: size)
                    .environmentObject(cameraController)
            }
            .frame(height: screen_rect.height / 2)
            .background(Color.black)
            .padding(.top)
            .overlay(
                Button(action: {
                    cameraController.flip()
                }) {
                    Image("flip.camera")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 32)
                .padding(.bottom, 32)
                ,alignment: .bottomLeading
            )
            .overlay(
                Button(action: {
                    cameraController.flash.toggle()
                }) {
                    Image("flash")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.trailing, 32)
                .padding(.bottom, 32)
                ,alignment: .bottomTrailing
            )
            
            Spacer(minLength: 0)
            
            Button(action: {}){
                Circle()
                    .fill(Color(hex: "#cdcdcd"))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                    )
                
            }
            
            Spacer(minLength: 0)
            
        }
    }
}
