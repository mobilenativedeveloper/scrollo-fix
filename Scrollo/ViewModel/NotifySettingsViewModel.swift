//
//  NotifySettingsViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI

class NotifySettingsViewModel: ObservableObject {
    @Published var load: Bool = false
    @Published var notify: NotifyModel = NotifyModel(newFollowers: false, newComments: false, newMessages: false, newReactions: false, newFollowingsPublications: false, newFollowersPublications: false)
    @Published var disableAll: Bool = false
    @Published var alert: AlertModel = AlertModel(title: "", message: "", show: false)
    
    init () {
        self.getSettingsNotify()
    }
    
    func getSettingsNotify () -> Void {
        self.load = true
        
        guard let url = URL(string: "\(API_URL)\(API_NOTIFY_SETTINGS)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(NotifyModel.self, from: data) else { return}
                
                DispatchQueue.main.async {
                    
                    self.notify = json
                    print(json)
                    if !json.newFollowers && !json.newComments && !json.newMessages && !json.newReactions && !json.newFollowingsPublications && !json.newFollowersPublications {
                        self.disableAll = true
                    }
                    self.load = true
                }
            }
            
        }
        .resume()
    }
    
    func changeSettingsNotify (body: [String: Bool]) -> Void {
        
        guard let url = URL(string: "\(API_URL)\(API_NOTIFY_SETTINGS)") else {return}
        guard let request = Request(url: url, httpMethod: "PATCH", body: body) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            
            
            
            if response.statusCode == 200 {
                guard let value = body.first?.value else {return}
                DispatchQueue.main.async {
                    if value {
                        self.disableAll = false
                    }
                }
            } else {
                self.alert = AlertModel(title: "Ошибка", message: "Невозможно изсенить параметр.", show: true)
            }
        }
        .resume()
    }
    
    func offAll () -> Void {
        var body: [String: Bool] = [:]
        
        if !self.disableAll {
            body = [
                "newFollowers": false,
                "newComments": false,
                "newMessages": false,
                "newReactions": false,
                "newFollowingsPublications": false,
                "newFollowersPublications": false
            ]
        } else {
            body = [
                "newFollowers": true,
                "newComments": true,
                "newMessages": true,
                "newReactions": true,
                "newFollowingsPublications": true,
                "newFollowersPublications": true
            ]
        }
        
        guard let url = URL(string: "\(API_URL)\(API_NOTIFY_SETTINGS)") else {return}
        guard let request = Request(url: url, httpMethod: "PATCH", body: body) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(NotifyModel.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.notify = json
                }
            }
        }
        .resume()
    }
}
