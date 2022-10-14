//
//  ContentView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 22.09.2022.
//

import SwiftUI

struct ContentView: View {

    @State var userId: String = UserDefaults.standard.value(forKey: "userId") as? String ?? String()

    init () {
        UIWindow.appearance().overrideUserInterfaceStyle = .light
        UITabBar.appearance().isHidden = true
    }
    
    @State var selectedTab = "home"
    
    @State var showMessanger: Bool = false
    @State var isScrollEnabled: Bool = true
    
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    
    @GestureState var gestureOffset: CGFloat = 0


    var body: some View {
        ZStack{
            NavigationView{
                if self.userId.isEmpty {
                    AuthView()
                        .ignoreDefaultHeaderBar
                    
                } else {
                    HStack(spacing: 0){
                        
                        
                        VStack(spacing: 0){
                            HomeView(selectedTab: $selectedTab, showMessanger: $showMessanger, isScrollEnabled: $isScrollEnabled)
                        }
                        .frame(width: getRect().width)
                        .frame(maxHeight: .infinity)
                        .background(Color.blue.ignoresSafeArea())
                        
                        VStack{
                            ChatListView(selectedTab: $selectedTab, isScrollEnabled: $isScrollEnabled, showMessanger: $showMessanger)
                        }
                        .frame(width: getRect().width)
                        .frame(maxHeight: .infinity)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                    }
                    .frame(width: getRect().width * 2)
                    .offset(x: getRect().width / 2)
                    .offset(x: offset < 0 ? offset : 0)
                    .gesture(
                        isScrollEnabled ? DragGesture()
                            .updating($gestureOffset, body: { value, out, _ in
                                out = value.translation.width
                            })
                            .onEnded(onEnded(value:)) : nil
                    )
                    .ignoreDefaultHeaderBar
                }
            }
            .animation(.easeOut, value: offset == 0)
            .onChange(of: showMessanger) { newValue in
                if isScrollEnabled{
                    if showMessanger && offset == 0{
                        offset = -getRect().width
                        lastOffset = offset
                    }
                    
                    if !showMessanger && offset == -getRect().width{
                        offset = 0
                        lastOffset = 0
                    }
                }
                
            }
            .onChange(of: gestureOffset) { newValue in
                if isScrollEnabled{
                    onChange()
                }
                
            }
        }
        .onAppear(perform: {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("userId"), object: nil, queue: .main) { (payload) in
                self.userId = UserDefaults.standard.value(forKey: "userId") as? String ?? String()
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("logout"), object: nil, queue: .main) { (payload) in
                self.userId = String()
            }
        })
    }
    
    func onChange(){
        let viewWidth = getRect().width
        
        offset = (gestureOffset != 0) ? (gestureOffset + lastOffset > -viewWidth ? gestureOffset + lastOffset : offset) : offset
    }
    
    func onEnded(value: DragGesture.Value){
        let viewWidth = getRect().width
        
        let translation = value.translation.width
        
        withAnimation {
            if translation < 0{
                if translation < -(viewWidth / 2){
                    offset = -viewWidth
                    showMessanger = true
                }
                else{
                    
                    if offset == -viewWidth{
                        return
                    }
                    
                    offset = 0
                    showMessanger = false
                }
            }
            else{
                if -translation < -(viewWidth / 2){
                    offset = 0
                    showMessanger = false
                }
                else{

                    if offset == 0 || !showMessanger{
                        return
                    }

                    offset = -viewWidth
                    showMessanger = true
                }
            }
        }
        
        lastOffset = offset
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


//struct ContentView: View {
//
//    @State var userId: String = UserDefaults.standard.value(forKey: "userId") as? String ?? String()
//
//    @State var offset: CGFloat = 0
//    @State var isDrag: Bool = false
//    @State var isScrollEnabled: Bool = false
//
//    @State var selectedTab = "home"
//
//    init () {
//        UIWindow.appearance().overrideUserInterfaceStyle = .light
//        UITabBar.appearance().isHidden = true
//    }
//
//    @State var currentOffset: CGFloat = 0
//    @State var prevOffste: CGFloat = 0
//
//    var body: some View {
//        ZStack{
//            if self.userId.isEmpty {
//                NavigationView{
//                    AuthView()
//                        .ignoreDefaultHeaderBar
//                }
//            } else {
//                ZStack{
//                    VStack{
//                        VStack{
//                            NavigationView{
//                                NewHomeView(selectedTab: $selectedTab, offset: $offset, isScrollEnabled: $isScrollEnabled, isScroll: self.isDrag).ignoreDefaultHeaderBar
//                            }
//                        }
//                        .frame( maxWidth: .infinity, maxHeight: .infinity)
//                    }
//                    .frame(width: getRect().width)
//                    .background(Color.red)
//                    .ignoresSafeArea()
//                    VStack{
//                        VStack{
//                            NavigationView{
//                                Color.blue.ignoreDefaultHeaderBar
//                            }
//                        }
//                        .frame( maxWidth: .infinity, maxHeight: .infinity)
//                    }
//                    .frame(width: getRect().width)
//                    .offset(x: getRect().width)
//                    .ignoresSafeArea()
//                }
//                .frame(width: getRect().width * 2)
//                .offset(x: self.currentOffset)
//                .ignoresSafeArea()
//                .gesture(
//                    DragGesture(minimumDistance: 50, coordinateSpace: .local)
//                        .onChanged({ value in
//                            self.isDrag = true
//                            let offsetX = value.translation.width + self.prevOffste
//
//                            if offsetX < 0 && offsetX > -(getRect().width){
//                                self.currentOffset = offsetX
//                            }
//                            else{
//                                self.currentOffset = 0
//                            }
//
//                        })
//                        .onEnded({ value in
//                            let offsetX = value.translation.width + self.prevOffste
//
//                            if offsetX < -(getRect().width/2){
//                                withAnimation {
//                                    self.currentOffset = -getRect().width
//                                }
//                                self.prevOffste = -getRect().width
//                            }
//                            else{
//                                withAnimation {
//                                    self.currentOffset = 0
//                                }
//                                self.prevOffste = 0
//                            }
//                            self.isDrag = false
//                        })
//                )
//            }
//        }
//        .onAppear(perform: {
//            NotificationCenter.default.addObserver(forName: NSNotification.Name("userId"), object: nil, queue: .main) { (payload) in
//                self.userId = UserDefaults.standard.value(forKey: "userId") as? String ?? String()
//            }
//            NotificationCenter.default.addObserver(forName: NSNotification.Name("logout"), object: nil, queue: .main) { (payload) in
//                self.userId = String()
//            }
//        })
//    }
//}


var edges = UIApplication.shared.windows.first?.safeAreaInsets

var screen_rect = UIScreen.main.bounds
