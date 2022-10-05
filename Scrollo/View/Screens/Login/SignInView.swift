//
//  SignInView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

struct SignInView: View{
    @ObservedObject var signInViewModel: SignInViewModel = SignInViewModel()
    @ObservedObject var keyboardHelper : KeyboardHelper = KeyboardHelper()
    var body: some View{
        ZStack(alignment: .center) {
            
            Color.white.ignoresSafeArea(.all)
                .overlay(
                    Image("logo_large")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.height / 4)
                        .offset(y: -((UIScreen.main.bounds.height / 4) / 1.5))
                    ,alignment: .center
                )
                .overlay(
                    
                    VStack {
                        Text("Войти в ваш Scrollo")
                            .font(.system(size: 27))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 19)
                            .padding(.top, 10)
                        Text("Введите ваше e-mail и пароль")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.bottom, 34)
                        
                        TextFieldLogin(value: self.$signInViewModel.email, placeholder: "E-mail")
                            .padding(.bottom, 14)
                        TextFieldLogin(value: self.$signInViewModel.password, placeholder: "Пароль", secure: true)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            if !self.signInViewModel.load {
                                self.signInViewModel.signIn()
                            }
                        }) {
                            
                            if self.signInViewModel.load {
                                ProgressView()
                            } else {
                                Text("Далее")
                                    .foregroundColor(.white)
                                    
                            }
                        }
                        .frame(width: 140, height: 56, alignment: .center)
                        .background(Color(hex: "#36D1DC"))
                        .cornerRadius(18.0)
                        .padding()
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 2) {
                            Text("Еще нет аккуанта?")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                            NavigationLink(destination: Text("")) {
                                Text("Зарегистрировать")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.9)
                        .background(
                            Color(hex: "#5B86E5")
                                .clipShape(CustomCorner(radius: 20, corners: [.topLeft, .topRight]))
                        )
                    ,alignment: .bottom
                )
        }
        .offset(y: -self.keyboardHelper.keyboardHeight)
        .animation(.spring())
        .ignoresSafeArea(.all)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .alert(isPresented: self.$signInViewModel.error, content: {
            Alert(title: Text("Ошибка"), message: Text(self.signInViewModel.errorMessage), dismissButton: .default(Text("Продолжить")))
        })
    }
}
