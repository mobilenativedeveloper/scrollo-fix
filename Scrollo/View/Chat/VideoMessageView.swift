//
//  VideoMessageView.swift
//  scrollo
//
//  Created by Artem Strelnik on 16.09.2022.
//

import SwiftUI

struct VideoMessageView: View {
    @Binding var message: MessageModel
    @Binding var showVideo: Bool
    @Binding var selectedVideo: MessageModel?
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            if message.type == "STARTER" {
                Spacer(minLength: 25)
                
                if message.video != nil{
                    // MARK: This web video
                }
                else {
                    Image(uiImage: message.asset!.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                        .contentShape(Rectangle())
                        .clipped()
                        .clipShape(CustomCorner(radius: 10, corners: [.topLeft, .bottomLeft, .bottomRight]))
                        .onTapGesture {
                            selectedVideo = message
                            showVideo = true
                        }
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .offset(x: -10, y: 10)
                            ,alignment: .topTrailing
                        )
                }
            }
            else {
                Image("testUserPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .clipped()
                Image("story1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                    .clipped()
                    .allowsHitTesting(false)
                    .background(Color(hex: "#F2F2F2"))
                    .clipShape(CustomCorner(radius: 10, corners: [.topRight, .bottomLeft, .bottomRight]))
                Spacer(minLength: 25)
            }
        }
        .padding(.vertical)
    }
}
