//
//  EmptyFeed.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct EmptyFeed: View{
    @State var currentIndex: Int = 0
    let data: [FrendModel] = [
        FrendModel(image: "natgeo_logo", login: "natgeo", career: "National Geographic", posts: [
            "https://picsum.photos/200/300?random=1",
            "https://picsum.photos/200/300?random=2",
            "https://picsum.photos/200/300?random=3",
        ], subtitle: "Популярное"),
        FrendModel(image: "nasa_logo", login: "nasa", career: "NASA", posts: [
            "https://picsum.photos/200/300?random=4",
            "https://picsum.photos/200/300?random=5",
            "https://picsum.photos/200/300?random=6",
        ], subtitle: "Популярное"),
        FrendModel(image: "marga_owski", login: "marga_owski", career: "Margarete Stokowski", posts: [
            "https://picsum.photos/200/300?random=7",
            "https://picsum.photos/200/300?random=8",
            "https://picsum.photos/200/300?random=9",
        ], subtitle: "Рекомендации Scrollo"),
        FrendModel(image: "natgeo_logo", login: "natgeo", career: "National Geographic", posts: [
            "https://picsum.photos/200/300?random=10",
            "https://picsum.photos/200/300?random=11",
            "https://picsum.photos/200/300?random=12",
        ], subtitle: "Популярное"),
        FrendModel(image: "marga_owski", login: "marga_owski", career: "Margarete Stokowski", posts: [
            "https://picsum.photos/200/300?random=13",
            "https://picsum.photos/200/300?random=14",
            "https://picsum.photos/200/300?random=15",
        ], subtitle: "Рекомендации Scrollo"),
        FrendModel(image: "nasa_logo", login: "nasa", career: "NASA", posts: [
            "https://picsum.photos/200/300?random=16",
            "https://picsum.photos/200/300?random=17",
            "https://picsum.photos/200/300?random=18",
        ], subtitle: "Популярное"),
    ]
    var body: some View{
        VStack(alignment: .center, spacing: 0) {
            Text("Добро пожаловать в Scrollo!")
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .padding(.bottom, 5)
            Text("Здесь будут показываться фото и видео людей, на которых вы подпишитесь.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 40)
            
            SnapCarousel(spacing: 0, trailingSpace: 160, index: $currentIndex, items: data) {account in
                GeometryReader{proxy in
                    RecommendationCard(account: account, proxy: proxy)
                }
            }
            .padding(.top)
        }
        .frame(height: 500)
    }
}
