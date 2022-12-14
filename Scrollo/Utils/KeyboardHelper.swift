//
//  KeyboardHelper.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import UIKit
import Foundation
import SwiftUI

class KeyboardHelper : ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    init() {
        self.listenKeyboardNotifications()
    }
    
    private func listenKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
                                                guard let userInfo = notification.userInfo,
                                                    let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                
            
            withAnimation(.easeInOut){
                self.keyboardHeight = keyboardRect.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
            withAnimation(.easeInOut){
                self.keyboardHeight = 0
            }
        }
    }
}
