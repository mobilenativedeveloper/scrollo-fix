//
//  NotifyModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI

struct NotifyModel: Decodable {
    var newFollowers: Bool
    var newComments: Bool
    var newMessages: Bool
    var newReactions: Bool
    var newFollowingsPublications: Bool
    var newFollowersPublications: Bool
    
    enum CodingKeys: CodingKey {
        case newFollowers, newComments, newMessages, newReactions, newFollowingsPublications, newFollowersPublications
    }
}
