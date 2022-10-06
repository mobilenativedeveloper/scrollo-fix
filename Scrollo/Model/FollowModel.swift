//
//  FollowModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 06.10.2022.
//

import SwiftUI

struct FollowersResponse: Decodable {
    var data: [FollowerModel]
    var page: Int
    var totalPages: Int
    var totalElements: Int
    
    enum CodingKeys: CodingKey {
        case data
        case page
        case totalPages
        case totalElements
    }
    
    
    
    struct FollowerModel: Decodable {
        var id: String
        var followOnUser: FollowModel
        var followedUser: FollowModel
        var createAt: Date
        var updatedAt: Date
        
        enum CodingKeys: CodingKey {
            case id
            case createAt
            case followOnUser
            case followedUser
            case updatedAt
        }
    }
    
    struct FollowModel: Decodable {
        var id: String
        var login: String?
        var career: String?
        var avatar: String?
        var type: String?
        
        enum CodingKeys: CodingKey {
            case id
            case login
            case career
            case avatar
            case type
        }
    }
}
