//
//  RecommendationCard.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecommendationCard: View{
    var account: FrendModel
    var proxy: GeometryProxy
    var body: some View{
        VStack{
            Image(account.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            
            Text(account.login)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .fontWeight(.bold)
            Text(account.career)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            HStack(spacing: 1){
                ForEach(0..<account.posts.count, id: \.self){index in
                    WebImage(url: URL(string: account.posts[index])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width/3.5, height: proxy.size.width/3.5)
                        .clipped()
                }
            }
            .padding(.horizontal, 5)
            
            Text(account.subtitle)
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.vertical, 7)
            
            Button(action:{}){
                Text("Подписаться")
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "#5B86E5"))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.1), radius: 15, x: 0, y: 0)
        )
        .padding(.vertical)
        .frame(width: proxy.size.width)
    }
}
