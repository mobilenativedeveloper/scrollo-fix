//
//  TextMessageView.swift
//  scrollo
//
//  Created by Artem Strelnik on 15.09.2022.
//

import SwiftUI

struct TextMessageView: View {
    @Binding var message: MessageModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            if message.type == "STARTER" {
                Spacer(minLength: 25)
                if message.content != nil {
                    Text(message.content!)
                        .font(.custom(GothamBook, size: 12))
                        .foregroundColor(.white)
                        .padding(.all)
                        .background(Color(hex: "#5B86E5"))
                        .clipShape(CustomCorner(radius: 10, corners: [.topLeft, .bottomLeft, .bottomRight]))
                }
            }
            else {
                
                Image("testUserPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .clipped()
                if message.content != nil {
                    Text(message.content!)
                        .font(.custom(GothamBook, size: 12))
                        .foregroundColor(Color(hex: "2E313C"))
                        .padding(.all)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "F2F2F2"), lineWidth: 1)
                        )
                }
                Spacer(minLength: 25)
            }
        }
        .padding(.vertical)
        .id(message.id)
    }
}

