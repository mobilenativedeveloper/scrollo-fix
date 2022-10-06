//
//  PostViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

class PostViewModel: ObservableObject{
    
    @Published var posts: [PostModel] = []
    
    @Published var page = 0
    let pageSize = 100
    
    func getPostsFeed(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_GET_FEED_POST)?page=\(page)&pageSize=\(pageSize)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else { return }
        
        URLSession.shared.dataTask(with: request) {(data, response, _) in
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                
                guard let data = data else {return}
                guard let json = try? JSONDecoder().decode(PostResponse.self, from: data) else { return }
                
                DispatchQueue.main.async {
                    self.posts = json.data
                    completion()
                }
            }
        }.resume()
    }
    
    func removePost(postId: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_POST)\(postId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else { return }

        URLSession.shared.dataTask(with: request) {(data, response, _) in
            guard let response = response as? HTTPURLResponse else {return}
            print(response.statusCode)
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }.resume()
    }
    
    func addLike (postId: String, completed: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_URL_LIKE)") else {return}
        guard let request = Request(url: url, httpMethod: "POST", body: ["postId": postId]) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completed()
                }
            }
        }.resume()
    }
    
    func removeLike (postId: String, completed: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_URL_LIKE)\(postId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completed()
                }
            }
        }.resume()
    }
    
    func addDislike (postId: String, completed: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_URL_DISLIKE)") else { return }
        guard let request = Request(url: url, httpMethod: "POST", body: ["postId": postId]) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    completed()
                }
            }
        }.resume()
    }
    
    func removeDislike (postId: String, completed: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_URL_DISLIKE)\(postId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completed()
                }
            }
        }.resume()
    }
}
