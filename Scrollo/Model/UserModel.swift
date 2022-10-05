//
//  UserModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI

struct UserModel: Decodable {
    var token: String
    var refreshToken: String
    var user: User
    
    
    enum CodingKeys: CodingKey {
        case token
        case refreshToken
        case user
    }
    
    struct User: Decodable {
        var id: String
        var login: String?
        var email: String?
        var phone: String?
        var background: String?
        var personal: Personal?
        var avatar: String?
        var createAt: String
        var updatedAt: String
        var postCount: Int
        var followersCount: Int
        var followingCount: Int
        var type: String?
        var direction: Direction?
        var career: String?
        
        enum CodingKeys: CodingKey {
            case login
            case email
            case id
            case phone
            case background
            case personal
            case avatar
            case createAt
            case updatedAt
            case postCount
            case followersCount
            case followingCount
            case type
            case direction
            case career
        }

    }
    
    struct Personal: Decodable {
        var region: String?
        var bio: String?
        var name: String?
        var gender: String?
        var website: String?
        
        enum CodingKeys: CodingKey {
            case region
            case bio
            case name
            case gender
            case website
        }
    }
    
    struct Direction: Decodable {
        var name: String?
        var displayName: String?
        
        enum CodingKeys: CodingKey {
            case name, displayName
        }
    }
}
