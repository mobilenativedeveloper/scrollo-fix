//
//  CommentsViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 05.10.2022.
//

import SwiftUI

struct Reply {
    var postCommentId : String
    var login : String
}

class CommentsViewModel: ObservableObject {
    
    @Published var comments : [PostModel.CommentsModel] = []
    
    @Published var load : Bool = false
    
    @Published var content : String = String()
    
    @Published var reply : Reply?
    
    func getPostComments (postId: String) -> Void {
        let url = URL(string: "\(API_URL)\(API_GET_COMMENTS)\(postId)?page=0&pageSize=10")!
        
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else { return }
        
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let _ = error { return }

            guard let response = response as? HTTPURLResponse else {return}

            if response.statusCode == 200 {
                if let json = try? JSONDecoder().decode(CommentsResponse.self, from: data!) {
                    DispatchQueue.main.async {
                        self.comments = json.data
                        withAnimation(.easeOut){
                            self.load = true
                        }
                    }
                }
            }
        }.resume()
    }
    
    func addComment (postId: String, completion: @escaping()->Void) -> Void {
        
        let url = URL(string: "\(API_URL)\(API_COMMENT)")!
        let data: [String: Any] = ["postId": postId, "comment": self.content]
        
        guard let request = Request(url: url, httpMethod: "POST", body: data) else { return }
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}

            if response.statusCode == 200 {
                if let comment = try? JSONDecoder().decode(PostModel.CommentsModel.self, from: data!) {
                    
                    DispatchQueue.main.async {
                        self.comments.append(comment)
                        completion()
                    }
                }
            }
        }.resume()
    }
    
    func addReply (postCommentId: String, completion: @escaping()->Void) -> Void {
        let url = URL(string: "\(API_URL)\(API_URL_ADD_REPLY_COMMENT)")!
        let data: [String: Any] = ["postCommentId": postCommentId, "content": self.content]
        
        guard let request = Request(url: url, httpMethod: "POST", body: data) else { return }
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}

            if response.statusCode == 200 {
                if let comment = try? JSONDecoder().decode(PostModel.LastSubComments.self, from: data!) {
                    
                    DispatchQueue.main.async {
                        guard let index = self.comments.firstIndex(where: {
                            $0.id == postCommentId
                        }) else { return }
                        
                        self.comments[index].lastSubComments.append(comment)
                        completion()
                    }
                }
            }
        }.resume()
    }
    
    func likeComment (postCommentId: String, completion: @escaping()->Void) -> Void {
        let url = URL(string: "\(API_URL)\(API_LIKE_COMMENT)")!
        let data: [String: Any] = ["postCommentId": postCommentId]
        
        guard let request = Request(url: url, httpMethod: "POST", body: data) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }.resume()
    }
    
    func likeRemoveComment (postCommentId: String, completion: @escaping()->Void) -> Void {
        let url = URL(string: "\(API_URL)\(API_LIKE_COMMENT)\(postCommentId)")!
        
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
           
            if response.statusCode == 200 {
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }.resume()
    }
    
    func replyLike (postCommentId: String, postCommentReplyId: String, completion: @escaping()->Void) -> Void {
        let url = URL(string: "\(API_URL)\(API_REPLY_LIKE)")!
        let data: [String: Any] = ["postCommentReplyId": postCommentReplyId]
        
        guard let request = Request(url: url, httpMethod: "POST", body: data) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            print("replyLike statusCode: \(response.statusCode), postCommentReplyId: \(postCommentReplyId)")
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }.resume()
    }
    
    func replyLikeRemove (postCommentId: String, postCommentReplyId: String,  completion: @escaping()->Void) -> Void {
        
        let url = URL(string: "\(API_URL)\(API_REPLY_LIKE)/\(postCommentReplyId)")!
        
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            if let token = UserDefaults.standard.string(forKey: "token"){
                print(token)
            }
            print("replyLikeRemove statusCode: \(response.statusCode), postCommentReplyId: \(postCommentReplyId)")
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }.resume()
    }
    
    func removeComment (commentId: String, completed: @escaping () -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_COMMENT)\(commentId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else { return }
            print(response.statusCode)
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completed()
                }
            }
        }.resume()
    }
}
