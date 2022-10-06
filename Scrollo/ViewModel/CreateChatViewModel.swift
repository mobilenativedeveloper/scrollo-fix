//
//  CreateChatViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 06.10.2022.
//

import SwiftUI

class CreateChatViewModel: ObservableObject{
    
    var load: Bool = false
    
    @Published var findUser: String = ""
    
    @Published var following: [FollowersResponse.FollowerModel] = []
    
    @Published var page = 0
    let pageSize = 100
    
    func getFollowing () {
        guard let url = URL(string: "\(API_URL)\(API_GET_USER_FOLLOWING)?page=\(page)&pageSize=\(pageSize)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(FollowersResponse.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.following = json.data
                    self.load = true
                }
            }
        }
        .resume()
    }
    
    func createChat (userId: String, completion: @escaping(ChatListModel.ChatModel?)->Void) {
        guard let url = URL(string: "\(API_URL)\(API_CHAT)") else {return}
        guard let request = Request(url: url, httpMethod: "POST", body: ["userId": userId]) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            guard let testJson = try? JSONSerialization.jsonObject(with: data, options: []) else {return}
            print(testJson)
            
            if response.statusCode == 201 {
                guard let chat = try? JSONDecoder().decode(ChatListModel.ChatModel.self, from: data) else {return}
                DispatchQueue.main.async {
                    completion(chat)
                }
            }
        }
        .resume()
    }
}
