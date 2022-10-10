//
//  ImageMessageView.swift
//  scrollo
//
//  Created by Artem Strelnik on 16.09.2022.
//

import SwiftUI

struct ImageMessageView: View {
    @Binding var message: MessageModel
    
    var animation: Namespace.ID
    @Binding var isExpanded: Bool
    @Binding var expandedMedia: MessageModel?
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            if message.type == "STARTER" {
                Spacer(minLength: 25)
                
                if expandedMedia?.id == message.id && isExpanded{
                    if message.image != nil{
                        Image("story1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                            .contentShape(Rectangle())
                            .clipped()
                            .cornerRadius(0)
                            .opacity(0)
                    }
                    else{
                        Image(uiImage: message.asset!.thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                            .contentShape(Rectangle())
                            .clipped()
                            .cornerRadius(0)
                            .opacity(0)
                    }
                } else {
                    if message.image != nil{
                        Image("story1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                            .contentShape(Rectangle())
                            .clipped()
                            .matchedGeometryEffect(id: message.id, in: animation)
                            .clipShape(CustomCorner(radius: 10, corners: [.topLeft, .bottomLeft, .bottomRight]))
                            .onTapGesture {
                                
                                withAnimation(.easeInOut(duration: 0.2)){
                                    expandedMedia = message
                                    isExpanded.toggle()
                                }
                            }
                    }
                    else {
                        Image(uiImage: message.asset!.thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                            .contentShape(Rectangle())
                            .clipped()
                            .matchedGeometryEffect(id: message.id, in: animation)
                            .clipShape(CustomCorner(radius: 10, corners: [.topLeft, .bottomLeft, .bottomRight]))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    expandedMedia = message
                                    isExpanded.toggle()
                                }
                            }
                    }
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
        .id(message.id)
    }
}

