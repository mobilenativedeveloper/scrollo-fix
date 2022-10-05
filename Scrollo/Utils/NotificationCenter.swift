//
//  NotificationCenter.swift
//  Scrollo
//
//  Created by Artem Strelnik on 25.09.2022.
//

import SwiftUI


extension View{
    func notificationCenter(name: String, completion: @escaping(Any?)->Void)->some View{
        self
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name(name), object: nil, queue: .main) { (payload) in
                    completion(payload.userInfo)
                }
            }
    }
}


func sendNotification(name: String, userInfo: [String: Any]){
    NotificationCenter.default.post(name: NSNotification.Name(name), object: nil, userInfo: userInfo)
}
