//
//  AuthViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI


class SignInViewModel: ObservableObject {
    @Published var load : Bool = false
    @Published var email: String = String()
    @Published var password: String = String()
    @Published var error: Bool = false
    @Published var errorMessage: String = String()
    
    private func verify() -> Bool? {
        if self.email.isEmpty && self.password.isEmpty {
            self.errorMessage = "Заполните все поля"
            self.error.toggle()
            return nil
        } else {
            return true
        }
    }
    
    func signIn () -> Void {
        
        guard let _ = self.verify() else { return }
        
        self.load = true
        
        let url = URL(string: "\(API_URL)\(API_AUTH)")!
        
        let body: [String: String] = ["email": self.email, "password": self.password.toBase64(), "device": UIDevice.current.name]
        
        if let request = Request(url: url, httpMethod: "POST", body: body) {
            
            URLSession.shared.dataTask(with: request){data, response, error in
                if let _ = error { return }
                
                guard let response = response as? HTTPURLResponse else {return}
                
                guard let debugJson = try? JSONSerialization.jsonObject(with: data!, options: []) else{return}
                
                debugPrint(debugJson)
                
                
                if response.statusCode == 200 {
                    if let user = try? JSONDecoder().decode(UserModel.self, from: data!) {
                        DispatchQueue.main.async {
                            debugPrint("OK")
                            self.load = false
                            UserDefaults.standard.set(user.token, forKey: "token")
                            UserDefaults.standard.set(user.user.id, forKey: "userId")
                            sendNotification(name: "userId", userInfo: [:])
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.load = false
                        self.errorMessage = "Неверный email или пароль"
                        self.error.toggle()
                    }
                }
            }.resume()
        }
    }
    
    
    
    
    
}
