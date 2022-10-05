//
//  EmojiListView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 05.10.2022.
//

import SwiftUI

struct EmojiListView: View {
    @Binding var comment: String
    let emoji: [String] = ["😍","😜","👍","😂","🙌","😉","🙏"]
    var body: some View {
        HStack {
            ForEach(0..<self.emoji.count, id: \.self) {index in
                Button(action: {
                    comment = comment + self.emoji[index]
                }) {
                    Text(self.emoji[index])
                }
                if index != self.emoji.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
    }
}
