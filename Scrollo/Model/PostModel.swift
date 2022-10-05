//
//  PostModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

struct PostModel:  Identifiable, Decodable {
    var id, content: String
    var creator: Creator
    var place: Place?
    var type: String?
    var likesCount, commentsCount, dislikeCount: Int
    var liked, commented, disliked, inSaved: Bool
    var files: [PostFiles]
    var lastComments: [CommentsModel]
//    var lastLikes: [LastLikes]?
    
    enum CodingKeys: CodingKey {
        case id
        case content
        case creator
        case place
        case type
        case likesCount
        case commentsCount
        case dislikeCount
        case liked
        case commented
        case disliked
        case inSaved
        case files
        case lastComments
//        case lastLikes
    }
    
    struct CommentsModel: Decodable {
        var id: String
        var comment: String
        var user: Creator
        var replyOn: ReplyOn?
        var likesCount: Int?
        var repliesCount: Int?
        var commented: Bool?
        var liked: Bool?
        var subCommentPageCount: Int?
        var lastSubComments: [LastSubComments]
        
        enum CodingKeys: CodingKey {
            case id
            case comment
            case user
            case replyOn
            case likesCount
            case repliesCount
            case commented
            case liked
            case subCommentPageCount
            case lastSubComments
        }
        
        struct ReplyOn: Decodable {
            var id: String
            var comment: String
            var content: String
            var user: Creator
            var likesCount: Int
            var commentsCount: Int
            var commented: Bool
            var liked: Bool
        }
    }
    
    struct LastSubComments: Decodable {
        var id: String
        var comment: Comment
        var content: String
        var user: Creator
        var liked: Bool?
        var likesCount: Int?
        
        struct Comment: Decodable {
            var id: String
            var comment: String
            var user: Creator
            var likesCount: Int?
            var repliesCount: Int?
            var commented: Bool?
            var liked: Bool?
        }
        
        enum CodingKeys: CodingKey {
            case id
            case comment
            case content
            case user
            case liked
            case likesCount
        }
    }
    
    struct Creator: Decodable {
        var id, login: String
        var name, avatar, region: String?
        
        enum CodingKeys: CodingKey {
            case id
            case login
            case name
            case avatar
            case region
        }
    }
    
    struct LastLikes: Decodable {
        var id: String
        var user: Creator
        
        enum CodingKeys: CodingKey {
            case id
            case user
        }
    }

    struct PostFiles: Decodable {
        var id: String
        var filePath: String?
        var type: String?
        var path: String?
        enum CodingKeys: CodingKey {
            case id
            case path
            case filePath
            case type
        }
    }

    struct Place: Decodable {
        var id, name: String
        
        enum CodingKeys: CodingKey {
            case id
            case name
        }
    }
}


struct PostResponse: Decodable {
    var data: [PostModel]
    var page: Int
    var totalPages: Int
}

struct CommentsResponse: Decodable {
    var data: [PostModel.CommentsModel]
}
