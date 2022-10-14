//
//  EndFeedView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct EndFeedView: View {
    var endFeed: Bool 
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(systemName: "checkmark")
                .font(.system(size: 21))
                .gradientForeground(colors: [Color(hex: "#5B86E5"), Color(hex: "#36DCD8")])
                .padding()
                .background(
                    Circle()
                        .strokeBorder(
                                AngularGradient(gradient: Gradient(colors: [Color(hex: "#5B86E5"), Color(hex: "#36DCD8")]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                                lineWidth: 2
                            )
                )
                .padding(.bottom)
                .scaleEffect(endFeed ? 1 : 0)
            Text("Вы посмотрели все обновления")
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .padding(.bottom, 5)
            Text("Вы посмотрели все новые публикации за последние 7д.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical)
        .transition(.opacity)
    }
}
