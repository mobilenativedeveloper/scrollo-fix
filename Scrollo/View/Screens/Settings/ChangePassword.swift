//
//  ChangePassword.swift
//  scrollo
//
//  Created by Artem Strelnik on 08.07.2022.
//

import SwiftUI

struct ChangePassword: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var changePasswordViewModel: ChangePasswordViewModel = ChangePasswordViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if !changePasswordViewModel.load {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image("comments_back")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("Смена пароля")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                    if !changePasswordViewModel.load {
                        changePasswordViewModel.change()
                    }
                }) {
                    if changePasswordViewModel.load {
                        ProgressView().frame(width: 24, height: 24)
                    } else {
                        Image("circle_blue_checkmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                }
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Пароль должен содержать не менее 6 символов, включая цифры, буквы и специальные символы (!$@%%)").font(.system(size: 13)).foregroundColor(.gray)
                        .padding()
                    TextField("Текущий пароль", text: $changePasswordViewModel.oldPassword)
                        .padding()
                        .padding(.bottom, 10)
                        .overlay(
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(height: 1).padding(),
                            alignment: .bottom
                        )
                    TextField("Новый пароль", text: $changePasswordViewModel.newPassword)
                        .padding()
                        .padding(.bottom, 10)
                        .overlay(
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(height: 1).padding(),
                            alignment: .bottom
                        )
                    TextField("Введите новый пароль еще раз", text: $changePasswordViewModel.confirmNewPassword)
                        .padding()
                        .padding(.bottom, 10)
                        .overlay(
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(height: 1).padding(),
                            alignment: .bottom
                        )
                }
            }
        }
        .background(Color(hex: "#F9F9F9"))
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
        .alert(isPresented: $changePasswordViewModel.alert.show) {
            Alert(title: Text(changePasswordViewModel.alert.title), message: Text(changePasswordViewModel.alert.message), dismissButton: .default(Text("Продолжить")))
        }
    }
}

struct ChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        ChangePassword()
    }
}
