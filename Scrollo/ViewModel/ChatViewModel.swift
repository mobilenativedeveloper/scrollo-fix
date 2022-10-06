//
//  ChatViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 06.10.2022.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    
    @Published var chats: [ChatListModel.ChatModel] = []
    @Published var loadChats : Bool = false
    var pageChat = 0
    var pageSizeChat = 100
    
    @Published var favoriteChats: [ChatListModel.ChatModel] = []
    
    func getChats (completion: @escaping()->Void) {
        guard let url = URL(string: "\(API_URL)\(API_CHAT)?page=\(pageChat)&pageSize=\(pageSizeChat)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
           
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(ChatListModel.self, from: data) else {return}
                self.getFavorites { favorites in
                    DispatchQueue.main.async {
                        var newChats = json.data
                        favorites.forEach { favorite in
                            newChats.removeAll(where: {$0.id == favorite.id})
                        }
                        
                        self.favoriteChats = favorites
                        self.chats = newChats
                        self.loadChats = true
                        completion()
                    }
                }
                
            }
        }
        .resume()
    }
    
    func removeChat(chatId: String){
        guard let url = URL(string: "\(API_URL)\(API_CHAT)\(chatId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.favoriteChats.removeAll(where: {$0.id == chatId})
                    self.chats.removeAll(where: {$0.id == chatId})
                }
            }
        }
        .resume()
    }
    
    func addFavorite (chat: ChatListModel.ChatModel) {
        guard let url = URL(string: "\(API_URL)\(API_CHAT_FAVORITE)") else {return}
        guard let request = Request(url: url, httpMethod: "POST", body: ["chatId": chat.id]) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            
            print(response.statusCode)
            if response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    withAnimation(.easeInOut){
                        self.favoriteChats.append(chat)
                        self.chats.removeAll(where: {$0.id == chat.id})
                    }
                }
            }
        }
        .resume()
    }
    
    func getFavorites (completion: @escaping([ChatListModel.ChatModel])->Void) {
        guard let url = URL(string: "\(API_URL)\(API_CHAT_FAVORITE)?page=\(pageChat)&pageSize=\(pageSizeChat)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(ChatListModel.self, from: data) else {return}
                completion(json.data)
            }
        }
        .resume()
    }
    
    func deleteFavorite (chat: ChatListModel.ChatModel) {
        guard let url = URL(string: "\(API_URL)\(API_CHAT_FAVORITE)\(chat.id)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut){
                        self.chats.append(chat)
                        self.favoriteChats.removeAll(where: {$0.id == chat.id})
                    }
                }
            }
        }
        .resume()
    }
}
