//
//  OTPField.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

struct OTPField: View {
    @Binding var otpField: String
    @State var isFocused = false
    
    var otp1: String
    var otp2: String
    var otp3: String
    var otp4: String
    var isTextFieldDisabled: Bool
    let textBoxWidth = UIScreen.main.bounds.width / 8
    let textBoxHeight = UIScreen.main.bounds.width / 8
    let spaceBetweenBoxes: CGFloat = 14
    let paddingOfBox: CGFloat = 1
    var textFieldOriginalWidth: CGFloat {
        (textBoxWidth*6)+(spaceBetweenBoxes*3)+((paddingOfBox*2)*3)
    }
    
    var body: some View {
        VStack {
            ZStack {
                HStack (spacing: spaceBetweenBoxes){
                    otpText(text: otp1)
                    otpText(text: otp2)
                    otpText(text: otp3)
                    otpText(text: otp4)
                }
                TextField("", text: $otpField)
                    .frame(width: isFocused ? 0 : textFieldOriginalWidth, height: textBoxHeight)
                    .disabled(isTextFieldDisabled)
                    .textContentType(.oneTimeCode)
                    .foregroundColor(.clear)
                    .accentColor(.clear)
                    .background(Color.clear)
                    .keyboardType(.numberPad)
            }
        }
    }
    
    private func otpText(text: String) -> some View {
              
        return Text(text)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: textBoxWidth, height: textBoxHeight)
                .background(VStack{
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#5B86E5"))
                        .frame(width: 50, height: 50)
                        .cornerRadius(10 - 1)
                        .padding(1)
                        .background(text.count == 1 ? Color(hex: "#36D1DC") : Color(hex: "#F2F2F2"))
                        .cornerRadius(10)
                    
                })
                .padding(paddingOfBox)
    }
}
