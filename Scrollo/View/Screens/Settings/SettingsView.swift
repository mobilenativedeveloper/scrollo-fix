//
//  SettingsView.swift
//  scrollo
//
//  Created by Artem Strelnik on 08.07.2022.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
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
                    Text("Настройки")
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
                .padding(.horizontal)
                .padding(.bottom)
                VStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            SettingsItemButton(label: "Пригласить друзей", icon: "invite")
                            NavigationLink(destination: AccountView().ignoreDefaultHeaderBar) {
                                SettingsItemButton(label: "Аккаунт", icon: "acoount")
                            }
                            NavigationLink(destination: SafetyView().ignoreDefaultHeaderBar) {
                                SettingsItemButton(label: "Безопастность", icon: "secure")
                            }
                            NavigationLink(destination: ConfidentialityView().ignoreDefaultHeaderBar) {
                                SettingsItemButton(label: "Конфеденциальность", icon: "privacy")
                            }
                            NavigationLink(destination: NotifyView().ignoreDefaultHeaderBar) {
                                SettingsItemButton(label: "Уведомления", icon: "alert")
                            }
                        }
                    }
                    Spacer()
                    Button(action: {
                        logout()
                    }) {
                        Text("Выйти из аккаунта")
                            .font(.system(size: 14))
                            .fontWeight(Font.Weight.semibold)
                            .foregroundColor(Color(hex: "#FF0F82"))
                    }
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .modifier(RoundedEdge(width: 1, color: Color(hex: "#FF0F82"), cornerRadius: 15))
                    )
                    .padding(.bottom)
                    Button(action: {
                        self.logout()
                    }) {
                        Text("Войти под другим аккаунтом")
                            .font(.system(size: 12))
                            .fontWeight(Font.Weight.semibold)
                            .foregroundColor(Color(hex: "#5B86E5"))
                    }
                }
                .padding(.bottom)
            }
            .ignoreDefaultHeaderBar
        }
    }
    
    func logout() {
        presentationMode.wrappedValue.dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "userId")
            
            NotificationCenter.default.post(name: NSNotification.Name("logout"), object: nil)
        }
        
    }
    
    @ViewBuilder
    func SettingsItemButton (label: String, icon: String) -> some View {
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
