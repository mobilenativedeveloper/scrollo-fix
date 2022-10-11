//
//  ModalView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 06.10.2022.
//

import SwiftUI

extension View{
    func navigationView<Content: View>(isPresent: Binding<Bool?>, content: @escaping() -> Content) -> some View{
        return NavigationViewHelper(isPresent: isPresent, mainContent: self, content: content())
    }
}

struct NavigationViewHelper<MainContent: View, Content: View>: View{
    
    var mainContent: MainContent
    var content: Content
    @Binding var isPresent: Bool?
    
    @GestureState var gestureState: CGFloat = 0
    @State var offset: CGFloat = 0
    
    init(isPresent: Binding<Bool?>, mainContent: MainContent, content: Content){
        self._isPresent = isPresent
        self.mainContent = mainContent
        self.content = content
    }
    
    var body: some View{
        GeometryReader{proxy in
            mainContent
                .offset(x: isPresent! && offset >= 0 ? getOffset(size: proxy.size.width) : 0)
                .overlay(
                    ZStack{
                        if isPresent!{
                            content
                                .background(Color.white.shadow(radius: 1.3).ignoresSafeArea())
                                .offset(x: offset > 0 ? offset : 0)
                                .gesture(DragGesture().updating($gestureState, body: { value, out, _ in
                                    out = value.translation.width
                                }).onEnded({ value in
                                    withAnimation(.linear.speed(2)){
                                        offset = 0
                                        
                                        let translation = value.translation.width
                                        
                                        let maxtranslation = proxy.size.width / 2.5
                                        
                                        if translation > maxtranslation{
                                            isPresent = false
                                        }
                                    }
                                }))
                                .transition(.move(edge: .trailing))
                        }
                    }
                )
                .onChange(of: gestureState) { newValue in
                    offset = newValue
                }
        }
    }
    
    func getOffset(size: CGFloat)->CGFloat{
        let progress = offset / size
        let start: CGFloat = -80
        let progressWidth = (progress * 90) <= 90 ? (progress * 90) : 90
        
        let mainOffset = (start + progressWidth) < 0 ? (start + progressWidth) : 0
        
        return mainOffset
    }
}
