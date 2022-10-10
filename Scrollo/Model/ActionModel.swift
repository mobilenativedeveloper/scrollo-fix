//
//  ActionModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 10.10.2022.
//

import SwiftUI

struct ActionResponse: Decodable {
    var data: [ActionModel]
    var page: Int
    var totalPages: Int
    var totalElements: Int
    
    enum CodingKeys: CodingKey {
        case data, page, totalPages, totalElements
    }
    

    struct ActionPost: Decodable {
        var id: String
        var content: String
        var preview: String?
        var type: String
        var creator: ActionModel.ActionUser
        
        enum CodingKeys: CodingKey {
            case id, content, preview, type, creator
        }
    }

 
    struct ActionModel: Decodable {
        var id: String
        var action: String
        var receiver: ActionUser
        var creator: ActionUser
        var post: ActionPost?
        var count: Int
        var comment: ActionComment?
        var content: String?
        var createdAt: String
        
        enum CodingKeys: CodingKey {
            case id, action, receiver, creator, post, count, comment, content, createdAt
        }
        
        struct ActionUser: Decodable {
            var id: String
            var login: String
            var name: String?
            var avatar: String?
            
            enum CodingKeys: CodingKey {
                case id, login, name, avatar
            }
        }
        
        struct ActionComment: Decodable {
            var id: String
            var comment: String
            enum CodingKeys: CodingKey {
                case id, comment
            }
        }
    }
}

struct ActionsSorted {
    var title: String
    var data: [ActionResponse.ActionModel]
}
