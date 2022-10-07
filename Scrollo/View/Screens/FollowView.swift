//
//  FollowView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI

struct FollowView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var currentTab: String = "followers"
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: 0){
            
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
                Text("login")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                   
                }) {
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                TabButton(title: "0 Подписчики", currentTab: $currentTab, animation: animation, id: "followers")
                TabButton(title: "0 Подписки", currentTab: $currentTab, animation: animation, id: "following")
            }
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
    }
}


