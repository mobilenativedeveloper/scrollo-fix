//
//  TabButton.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI

struct TabButton: View{
    var title: String
    @Binding var currentTab: String
    var animation: Namespace.ID
    var id: String
    var body: some View{
        Button(action: {
            withAnimation{
                currentTab = id
            }
        }) {
            LazyVStack(spacing: 12){
                Text(title)
                    .font(.custom(currentTab == id ? GothamBold : GothamBook, size: 13))
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: id == title ? "#5B86E5" :  "#333333"))
                    .padding(.horizontal)
                
                if currentTab == id{
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#5B86E5"))
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                }
                else{
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
        }
    }
}
