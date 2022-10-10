//
//  VideoOverviewView.swift
//  scrollo
//
//  Created by Artem Strelnik on 17.09.2022.
//

import SwiftUI

struct VideoOverviewView: View {
    @Binding var loadExpandedContentVideo: Bool
    @Binding var isExpandedVideo: Bool
    @Binding var expandedMediaVideo: MessageModel?
    var animationVideo: Namespace.ID
    @Binding var offsetVideo: CGSize
    var offsetProgressVideo: CGFloat
    
    @State var isShare: Bool = false
    
    var body: some View {
        VStack{
            
        }
    }
}
