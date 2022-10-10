//
//  MessageViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 10.10.2022.
//

import SwiftUI

class MessageViewModel: ObservableObject{
    
    @Published var message : String = String()
    
    @Published var messages: [MessageModel] = []
    
    func sendMessage(message: MessageModel){
        self.messages.append(message)
    }
}
