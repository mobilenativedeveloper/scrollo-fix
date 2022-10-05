//
//  PullToRefresh.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI


extension View{
    func pullToRefresh(refreshing: Binding<Bool>, backgroundColor: Color, onRefresh: @escaping(@escaping()->Void)->Void)-> some View{
        RefreshableScrollView(refreshing: refreshing, backgroundColor: backgroundColor, onRefresh: onRefresh){
            self
        }
    }
}

struct RefreshableScrollView<Content: View>: View {
    let content: Content
    
    let onRefresh: (@escaping()->Void) -> ()
    @Binding var refreshing: Bool
    let backgroundColor: Color
    
    @State var isRefresh: Bool = false
    @State var startPos: CGFloat = 0.0
    @State var currentOffset: CGFloat = 0.0
    @State var isAllowRefresh: Bool = false
    
    let offset: CGFloat = 100
    
    init(refreshing: Binding<Bool>, backgroundColor: Color, onRefresh: @escaping(@escaping()->Void)->Void, @ViewBuilder content: @escaping()->Content){
        self._refreshing = refreshing
        self.backgroundColor = backgroundColor
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View{
        ZStack(alignment: .top){
            HStack(spacing: 0){
                Spacer()
                ActivityIndicator(isAnimating: $isRefresh, color: Color.black)
                Spacer()
            }
            .frame(height: offset)
            .background(backgroundColor)
            
            ScrollView{
                GeometryReader{proxy -> Color in
                    DispatchQueue.main.async {
                        if self.startPos == 0 {
                            self.startPos = proxy.frame(in: .global).midY
                        }
                        
                        self.currentOffset = proxy.frame(in: .global).midY
                        
                        if self.currentOffset < self.startPos{
                            self.isAllowRefresh = false
                        }
                        else if self.currentOffset == self.startPos && !self.isAllowRefresh {
                            self.isAllowRefresh = true
                        }
                        
                        if self.isAllowRefresh{
                            if (proxy.frame(in: .global).midY - self.startPos) > offset {
                                if !self.isRefresh {
                                    withAnimation(.spring()){
                                        self.isRefresh = true
                                        onRefresh(done)
                                    }
                                }
                            }
                        }
                    }
                    return Color.white
                }
                .frame(height: 0)
                
                VStack(spacing: 0){
                    content
                }
                .background(backgroundColor)
                .offset(y: self.isRefresh ? offset - (self.currentOffset - self.startPos) : 0)
            }
        }
    }
    
    func done(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()){
                self.isRefresh = false
            }
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    
    let color: Color
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        
        let controller = UIActivityIndicatorView()
        controller.color = UIColor(color)
        controller.style = .medium
        controller.hidesWhenStopped = false
        return controller
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
