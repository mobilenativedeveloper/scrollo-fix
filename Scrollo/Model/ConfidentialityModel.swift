//
//  ConfidentialityModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI

struct ConfidentialityModel: Decodable {
    var writeComments: String
    var mark: String
    var writeMessage: String
    
    enum CodingKeys: CodingKey {
        case writeComments, mark, writeMessage
    }
}
