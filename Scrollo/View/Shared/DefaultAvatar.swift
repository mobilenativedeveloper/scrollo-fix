//
//  DefaultAvatar.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

struct DefaultAvatar: View {
    
    let width : CGFloat
    let height : CGFloat
    let background : Color
    let cornerRadius : CGFloat
    
    init (width: CGFloat, height: CGFloat, cornerRadius: CGFloat, background: Color = Color.white) {
        self.width = width
        self.height = height
        self.background = background
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        VStack {
            Image("default_avatar")
                .resizable()
                .scaledToFill()
                .frame(width: self.width, height: self.height)
        }
        .frame(width: self.width, height: self.height)
        .background(self.background)
        .cornerRadius(self.cornerRadius)
    }
}
