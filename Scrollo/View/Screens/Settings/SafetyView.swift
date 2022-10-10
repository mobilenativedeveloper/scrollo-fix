//
//  SafetyView.swift
//  scrollo
//
//  Created by Artem Strelnik on 08.07.2022.
//

import SwiftUI

struct SafetyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle.left.arrow.black")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("Безопастность")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                    
                }) {
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom)
            ScrollView {
                VStack(spacing: 0) {
                    NavigationLink(destination: ChangePassword().ignoreDefaultHeaderBar) {
                        SafetyItemButton(label: "Пароль", icon: "password")
                    }
                    SafetyItemButton(label: "Двухфакторная аутентификация", icon: "two-factor_authentication")
                    SafetyItemButton(label: "Входы в аккаунт", icon: "account_logins")
                }
            }
        }
        .background(Color(hex: "#F9F9F9"))
    }
    
    @ViewBuilder
    func SafetyItemButton (label: String, icon: String) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 21, height: 21)
            Text("\(label)")
                .font(.system(size: 12))
                .foregroundColor(Color.black)
                .fontWeight(Font.Weight.semibold)
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}
