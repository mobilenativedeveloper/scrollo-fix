//
//  TextFieldLogin.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

struct TextFieldLogin: View {
    @Binding var value: String
    private let placeholder: String
    private let secure: Bool
    
    public init (value: Binding<String>, placeholder: String, secure: Bool = false) {
        self._value = value
        self.placeholder = placeholder
        self.secure = secure
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 1)
            if self.secure {
                SecureField("", text: self.$value)
                    .placeholder(when: self.value.isEmpty) {
                            Text(self.placeholder).foregroundColor(.white)
                    }
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                    .frame(height: 56)
                    .padding(.horizontal)
                    .padding(.horizontal, 5)
                
            } else {
                TextField("", text: self.$value)
                    .placeholder(when: self.value.isEmpty) {
                            Text(self.placeholder).foregroundColor(.white)
                    }
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                    .frame(height: 56)
                    .padding(.horizontal)
                    .padding(.horizontal, 5)
            }
            
            
        }
        .frame(height: 56)
        .padding(.horizontal)
    }
}
