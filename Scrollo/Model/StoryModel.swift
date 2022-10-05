//
//  StoryModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI

struct StoryModel: Identifiable, Hashable {
    var id = UUID().uuidString
    var profileName: String
    var profileImage: String
    var isSeen: Bool
    var stories: [Story]
}

struct Story: Identifiable, Hashable {
    var id = UUID().uuidString
    var imageUrl: String
}
