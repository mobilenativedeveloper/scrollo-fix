//
//  HomeView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI
import UIKit

struct DashboardView: View {
    @State var offset: CGFloat = 0
    @State var isScrollEnabled: Bool = false
    
    @State var selectedTab = "home"
    
    @State var rect: CGRect?
    
    var body: some View {
        
        GeometryReader{reader in
            let frame = reader.frame(in: .global)
            ZStack{
                if let r = rect{
                    ScrollableTabBar(
                        tabs: ["", ""],
                        rect: r,
                        offset: $offset,
                        isScrollEnabled: true
                    ) {
                        Color.green.ignoreDefaultHeaderBar
                        Color.blue.ignoreDefaultHeaderBar
                    }
                    .ignoresSafeArea()
                }
            }
            .ignoresSafeArea()
            .onChange(of: frame) { newSize in
                rect = newSize
                
            }
        }
        .ignoresSafeArea()
    }
}
