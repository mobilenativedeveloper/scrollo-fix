//
//  PublicationTextPost.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

struct PublicationTextPostView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var addPost: AddTextPostViewModel = AddTextPostViewModel()
    
    var body: some View {
        VStack {
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
                Text("написать пост")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#2E313C"))
                Spacer(minLength: 0)
                Button(action: {
                    if !addPost.load {
                        addPost.publish { post in
                            guard let post = post else {return}
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    if addPost.load {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Image("circle.right.arrow.blue")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                }
            }
            .padding(.top)
            .padding(.horizontal)
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                TextEditor(text: $addPost.content)
                    .padding()
                    .background(Color.white)
                    .frame(width: UIScreen.main.bounds.width - 43, height: 303)
                    .cornerRadius(10)
                    .padding(.top, 10)
                if (addPost.content.count == 0) {
                    Text("Ваш пост...")
                        .foregroundColor(Color(hex: "#909090"))
                        .padding()
                        .padding(.top, 19)
                        .padding(.leading, 6)
                }
            }
            ColorBlock()
            Spacer()
        }
        .background(Color(hex: "#F9F9F9").edgesIgnoringSafeArea(.all))
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
//        .alert(isPresented: $addPost.error) {
//            Alert(title: Text(addPost.alert.title), message: Text(addPost.errorMessage), dismissButton: .default(Text("Продолжить")))
//        }
    }
}

private struct ColorBlock : View {
    let colors = ["#000000", "#8A8A8F", "#EFEFF4", "#007AFF", "#4CD964", "#FF9500", "#A644FF"]
    var body: some View {
        HStack {
            ForEach(0..<self.colors.count, id: \.self) {index in
                Button(action: {}) {
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(width: 29, height: 29)
                            .shadow(color: Color.black.opacity(0.30), radius: 4, x: 0.0, y: 2.0)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: self.colors[index]))
                            .frame(width: 26, height: 26)
                    }
                }
                    
            }
            Spacer(minLength: 0)
            Button(action: {}) {
                Image("settings_button")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 21)
        .padding(.top, 15)
    }
}
