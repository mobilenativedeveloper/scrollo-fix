//
//  AccountView.swift
//  scrollo
//
//  Created by Artem Strelnik on 08.07.2022.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var account: AccountViewModel = AccountViewModel()
    
    @State var user: UserModel.User? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if !account.load {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                }) {
                    if account.load {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Image("circle.left.arrow.black")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                    }
                }
                Spacer(minLength: 0)
                Text("Аккаунт")
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
            
            if let user = self.user {
                ScrollView {
                    Toggle(isOn: $account.userAccountType, label: {
                        Text("Закрытый аккаунт")
                            .font(.system(size: 12))
                            .foregroundColor(Color.black)
                            .fontWeight(Font.Weight.semibold)
                    })
                        .onTapGesture {
                            if !account.load {
                                account.switchUserType()
                            }
                        }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    
                    AccountButton(label: "Язык приложения", action: {})
                    AccountButton(label: "Мои интересы", action: {})
                    Toggle(isOn: $account.accessPhoneBook, label: {
                        Text("Доступ к телефонной книге")
                            .font(.system(size: 12))
                            .foregroundColor(Color.black)
                            .fontWeight(Font.Weight.semibold)
                    })
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .onAppear {
                    if user.type == "CLOSED" { account.userAccountType = true }
                    if user.type == "OPEN" { account.userAccountType = false }
                    
                }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            getProfile(userId: UserDefaults.standard.string(forKey: "userId")!)
        }
    }
    
    func getProfile (userId: String) -> Void {
        
        let url = URL(string: "\(API_URL)\(API_USER)\(userId)")!
        
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(UserModel.User.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.user = json
                }
            }
        }.resume()
    }
}


private struct AccountButton: View {
    let label: String
    let action: () -> Void
    
    init (label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack {
                Text("\(self.label)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.black)
                    .fontWeight(Font.Weight.semibold)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
