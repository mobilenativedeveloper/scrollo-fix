//
//  FeedStoryList.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct FeedStoryList: View {
    @StateObject var storyData: StoryViewModel = StoryViewModel()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 0) {
                StoriesUserListItem()
                    .environmentObject(storyData)
                    .padding(.leading)
                
                ForEach(0..<storyData.stories.count){index in
                    StoriesListItem(story: storyData.stories[index])
                        .environmentObject(storyData)
                        .padding(.leading, 10)
                }
            }
            .fullScreenCover(isPresented: $storyData.showStory) {
                StoryView()
                    .environmentObject(storyData)
            }
        }
    }
}
