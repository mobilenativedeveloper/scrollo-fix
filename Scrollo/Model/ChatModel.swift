//
//  ChatModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 06.10.2022.
//

import SwiftUI

struct ChatListModel: Decodable {
    var data: [ChatModel]
    var page: Int
    var totalPages: Int
    var totalElements: Int
    
    enum CodingKeys: CodingKey {
        case data, page, totalPages, totalElements
    }
    
    struct ChatModel: Decodable {
        var id: String
        var starter: ChatUser
        var receiver: ChatUser
        
        enum CodingKeys: CodingKey {
            case id, starter, receiver
        }
        
        
        struct ChatUser: Decodable {
            var id: String
            var login: String
            var name: String?
            var avatar: String?
            
            enum CodingKeys: CodingKey {
                case id, login, name, avatar
            }
        }
    }
}

struct MessageModel: Identifiable, Equatable{
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return true
    }
    
    var id = UUID().uuidString
    var type: String
    var content: String?
    var audio: URL?
    var image: String?
    var video: String?
    var date: Date = Date()
    var asset: AssetModel?
}
