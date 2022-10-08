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
    
    func getUserTextPosts (userId: String, completion: @escaping([PostModel])->Void) -> Void {
        guard let url = URL(string: "\(API_URL)\(API_USER_POST)\(userId)?page=0&pageSize=100&type=TEXT") else {return}
        
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                
                guard let posts = try? JSONDecoder().decode(PostResponse.self, from: data) else {return}
                
                DispatchQueue.main.async {
                    completion(posts.data)
                }
            }
            
        }.resume()
    }
    
    func getUserMediaPosts (userId: String, completion: @escaping ([[[PostModel]]]) -> Void) -> Void {
        
        guard let url = URL(string: "\(API_URL)\(API_USER_POST)\(userId)?page=0&pageSize=100&type=STANDART") else {return}
        
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                
                guard let posts = try? JSONDecoder().decode(PostResponse.self, from: data) else {return}
                
                DispatchQueue.main.async {
                    if posts.data.count > 0 {
                        let composition = self.createCompositionLayer(posts: posts.data)
                        completion(composition)
                    } else {
                        completion([])
                    }
                }
            }
            
        }.resume()
    }
    
    func createCompositionLayer (posts: [PostModel]) -> [[[PostModel]]] {
        var postComposition: [[[PostModel]]] = []
        var composition: [[PostModel]] = []
        var stack: [PostModel] = []
        
        for (index, post) in posts.enumerated() {
            stack.append(post)

            if stack.count == 2 || (stack.count == 1 &&  index == posts.count - 1) {
                composition.append(stack)
                stack.removeAll()
            }
            
            if composition.count == 3 || (composition.count == 2 && index == posts.count - 1) || (composition.count == 1 && index == posts.count - 1) {

                postComposition.append(composition)
                composition.removeAll()
            }
        }
        
        return postComposition
    }
    
    func savePost (postId: String, albumId: String?, completion: @escaping () -> Void) -> Void {
        
        guard let url = URL(string: "\(API_URL)\(API_POST_SAVE)") else {return}
        
        guard let request = Request(url: url, httpMethod: "POST", body: albumId == nil ? ["postId": postId] : ["postId": postId, "albumId": albumId!]) else {return}
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            
            print("savePost: \(response.statusCode)")
            if response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    completion()
                }
            }
            
        }.resume()
    }
    
    func unSavePost (postId: String, completion: @escaping () -> Void) -> Void {
        
        guard let url = URL(string: "\(API_URL)\(API_POST_SAVE)/\(postId)") else {return}
        
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            
            print("unSavePost: \(response.statusCode)")
            if response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    completion()
                }
            }
            
        }.resume()
    }
}
