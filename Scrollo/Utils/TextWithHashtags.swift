//
//  TextWithHashtags.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI

func textWithHashtags(_ text: String, color: Color) -> Text {
    let words = text.split(separator: " ")
    var output: Text = Text("")

    for word in words {
        if word.hasPrefix("#") { // Pick out hash in words
            output = output + Text(" ") + Text(String(word))
                .foregroundColor(color) // Add custom styling here
        } else {
            output = output + Text(" ") + Text(String(word))
        }
    }
    return output
}
