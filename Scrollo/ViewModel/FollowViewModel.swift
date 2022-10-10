//
//  FollowViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI


class FollowViewModel: ObservableObject{
    
    @Published var loadFollowers: Bool = false
    @Published var loadFollowing: Bool = false
    
    @Published var followers: [FollowersResponse.FollowerModel] = []
    @Published var following: [FollowersResponse.FollowerModel] = []
    
    @Published var page = 0
    let pageSize = 100
    
    //MARK: Get all user followers
    func getFollowers (completion: @escaping()->Void) {
        guard let url = URL(string: "\(API_URL)\(API_GET_USER_FOLLOWERS)?page=\(page)&pageSize=\(pageSize)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(FollowersResponse.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.followers = json.data
                    self.loadFollowers = true
                    completion()
                }
            }
        }
        .resume()
    }
    
    //MARK: Get all user following
    func getFollowing (completion: @escaping()->Void) {
        guard let url = URL(string: "\(API_URL)\(API_GET_USER_FOLLOWING)?page=\(page)&pageSize=\(pageSize)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(FollowersResponse.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.following = json.data
                    self.loadFollowing = true
                    completion()
                }
            }
        }
        .resume()
    }
    
    //MARK: Unfollow on user
    func unFollowOnUser(userId: String, completion: @escaping(Bool?)->Void){
        guard let url = URL(string: "\(API_URL)\(API_FOLLOW_ON_USER)\(userId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
        .resume()
    }
    
    //MARK: Follow on user
    func followOnUser(userId: String, completion: @escaping(Bool?)->Void){
        guard let url = URL(string: "\(API_URL)\(API_FOLLOW_ON_USER)") else {return}
        guard let request = Request(url: url, httpMethod: "POST", body: ["userId": userId]) else {return}
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
        .resume()
    }
    
    //MARK: Delete user follower
    func deleteFollower(userId: String, completion: @escaping(Bool?)->Void){
        guard let url = URL(string: "\(API_URL)\(API_REMOVE_FOLLOWER)\(userId)") else {return}
        guard let request = Request(url: url, httpMethod: "DELETE", body: nil) else {return}
    
        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
        .resume()
    }
    
    //MARK: Check follow on user
    func checkFollowOnFollower(userId: String, completion: @escaping(Bool?)->Void){
        guard let url = URL(string: "\(API_URL)\(API_CHECK_FOLLOW_ON_USER)\(userId)") else {return}
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
    
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else{return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(ResponseResult.self, from: data) else{return}
                
                DispatchQueue.main.async {
                    if json.result == true {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
        .resume()
    }
    
}
