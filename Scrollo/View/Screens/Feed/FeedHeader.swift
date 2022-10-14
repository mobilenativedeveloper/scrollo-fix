//
//  FeedHeader.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct FeedHeader: View {
    @Binding var showMessanger: Bool
    var body: some View {
        HStack {
            Image("logo_large")
                .resizable()
                .frame(width: 95, height: 21)
            Spacer()
            Button(action: {
                showMessanger = true
            }){
                Image("messanger")
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
            }
        }
        .padding(.horizontal)
        .background(Color(hex: "#F9F9F9"))
    }
}
