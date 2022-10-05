//
//  StoryViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI

class StoryViewModel : ObservableObject {
    @Published var load : Bool = false
    @Published var stories : [StoryModel] = [
        StoryModel(profileName: "suncitydn", profileImage: "testUserPhoto", isSeen: false, stories: [
            Story(imageUrl: "story1"),
            Story(imageUrl: "story2"),
        ]),
        StoryModel(profileName: "sunny", profileImage: "testUserPhoto", isSeen: false, stories: [
            Story(imageUrl: "story3"),
            Story(imageUrl: "story4"),
        ])
    ]
    @Published var showStory: Bool = false
    @Published var currentStory: String = ""
    
    init () {
        self.load = true
    }
}
