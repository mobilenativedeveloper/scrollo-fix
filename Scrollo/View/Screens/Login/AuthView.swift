//
//  AuthView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI

struct AuthView: View {
    
    var body: some View {
        ZStack(alignment: .center) {
            
            LinearGradient(gradient: Gradient(colors: [
                Color(hex: "#36DCD8"),
                Color(hex: "#5B86E5")
            ]), startPoint: .leading, endPoint: .topTrailing).ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                Image("logo_large")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 321, height: 71)
                
                Spacer()
                NavigationLink(destination: SignInView()){
                    RoundedRectangle(cornerRadius: 18.0)
                        .fill(Color(hex: "#5B86E5"))
                        .frame(width: 258, height: 56, alignment: .center)
                        .padding()
                        .overlay(
                            Text("Войти")
                                .foregroundColor(.white)
                        )
                }
                NavigationLink(destination: SignUpView().ignoreDefaultHeaderBar){
                    Text("Зарегистрироваться")
                        .frame(width: 258, height: 56, alignment: .center)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 1)
                        )
                }
                Spacer()
                
                Group {
                    Text("Используя приложения вы соглашаетесь с ") + Text("договором оферты ").bold() + Text("и ") + Text("политикой конфеденциальности").bold()
                }
                .foregroundColor(.white)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom)
            }
        }
    }
}
