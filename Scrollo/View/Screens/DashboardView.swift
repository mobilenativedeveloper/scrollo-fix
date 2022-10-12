//
//  HomeView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI
import UIKit

struct DashboardView: View {
    @State var show: Bool = false
    @State var offset: CGFloat = 0
    @State var isScrollEnabled: Bool = false
    @State var selectedTab = "home"
    
    var body: some View {
        GeometryReader{proxy in
            let rect = proxy.frame(in: .global)
            ScrollableTabBar(tabs: ["", ""], rect: rect, offset: $offset, isScrollEnabled: isScrollEnabled, show: $show) {
                HomeView(selectedTab: $selectedTab, offset: $offset, isScrollEnabled: $isScrollEnabled)
                    .frame(width: rect.width, height: rect.height)
                ChatListView(offset: $offset, selectedTab: $selectedTab, isScrollEnabled: $isScrollEnabled)
                    .frame(width: rect.width, height: rect.height)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}




struct ScrollableTabBar<Content: View>: UIViewRepresentable{
    var content: Content
    
    var rect: CGRect
    
    @Binding var offset: CGFloat
    
    var tabs: [Any]
    
    var isScrollEnabled: Bool
    
    @Binding var show: Bool
    
    init (tabs: [Any], rect: CGRect, offset: Binding<CGFloat>, isScrollEnabled: Bool, show: Binding<Bool>, @ViewBuilder content: () -> Content){
        self.content = content()
        self._offset = offset
        self.rect = rect
        self.tabs = tabs
        self._show = show
        self.isScrollEnabled = isScrollEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        return ScrollableTabBar.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        
        let scrollView = UIScrollView()
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.contentSize = CGSize(width: rect.width * CGFloat(tabs.count), height: 1.0)
       
        let controller = UIHostingController(rootView: HStack(spacing: 0){content})
        controller.view.frame = CGRect(x: 0, y: 0, width: rect.width * CGFloat(tabs.count), height: rect.height)
        
        if let view = controller.view{
            
            scrollView.addSubview(view)
        }
        
        scrollView.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
        uiView.isScrollEnabled = isScrollEnabled
        
        if uiView.contentOffset.x != offset{
            
            uiView.delegate = nil
            
            
            UIView.animate(withDuration: 0.4) {
                uiView.contentOffset.x = offset
            } completion: { (status) in
                if status{
                    uiView.delegate = context.coordinator
                }
            }
        }
    }
    
    
    class Coordinator: NSObject, UIScrollViewDelegate{
        var parent: ScrollableTabBar
        
        init(parent: ScrollableTabBar){
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.x
        }
    }
}

