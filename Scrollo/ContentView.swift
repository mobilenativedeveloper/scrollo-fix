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
    
    var body: some View {
        
        NavigationView{
            VStack{
                if self.userId.isEmpty {
                    AuthView()
                } else {
                    DashboardView()
                }
            }
            .frame(width: screen_rect.width, height: screen_rect.height)
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .navigationBarTitle(Text("Scrollo"))
//            .edgesIgnoringSafeArea([.top, .bottom])
            .onAppear(perform: {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("userId"), object: nil, queue: .main) { (payload) in
                    self.userId = UserDefaults.standard.value(forKey: "userId") as? String ?? String()
                }
                NotificationCenter.default.addObserver(forName: NSNotification.Name("logout"), object: nil, queue: .main) { (payload) in
                    self.userId = String()
                }
            })
        }
    }
}

var edges = UIApplication.shared.windows.first?.safeAreaInsets
var screen_rect = UIScreen.main.bounds
