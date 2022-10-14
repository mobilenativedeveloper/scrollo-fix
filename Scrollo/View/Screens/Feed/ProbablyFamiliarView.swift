//
//  ProbablyFamiliarView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct ProbablyFamiliarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Возможно вам знакомы")
                .font(.custom(GothamBold, size: 12))
                .foregroundColor(.black)
                .padding(.top, 18)
                .padding(.bottom, 8)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self){index in
                        ProbablyFamiliarItem(photo: "story1", username: "Андрей Булкин", login: "@Andy_bakkery")
                            .padding(.trailing, index == 6 ? 0 : 19)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func ProbablyFamiliarItem(photo: String, username: String, login: String) -> some View {
        VStack(spacing: 0) {
            Image(photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 94, height: 91)
                .cornerRadius(15)
                .padding(.horizontal, 4)
                .padding(.top, 5)
                .padding(.bottom, 6)
            Text(username)
                .font(.custom(GothamBold, size: 8))
                .foregroundColor(.black)
                .padding(.bottom, 3)
            Text(login)
                .font(.custom(GothamBook, size: 7))
                .foregroundColor(Color(hex: "#919191"))
                .padding(.bottom, 9)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color(hex: "#040404").opacity(0.1), radius: 4, x: 0, y: 0)
    }
}
