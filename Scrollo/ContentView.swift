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
        if self.userId.isEmpty {
            NavigationView{
                AuthView()
                    .ignoreDefaultHeaderBar
            }
        } else {
            DashboardView()
                .ignoreDefaultHeaderBar
                .notificationCenter(name: "userId", completion: { userInfo in
                    self.userId = UserDefaults.standard.value(forKey: "userId") as? String ?? String()
                })
                .notificationCenter(name: "logout", completion: { userInfo in
                    self.userId = String()
                })
        }
        
    }
}

var edges = UIApplication.shared.windows.first?.safeAreaInsets
var screen_rect = UIScreen.main.bounds
