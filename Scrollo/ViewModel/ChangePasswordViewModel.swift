//
//  ChangePasswordViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI



class ChangePasswordViewModel: ObservableObject {
    
    @Published var load: Bool = false
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""

    @Published var alert: AlertModel = AlertModel(title: "", message: "", show: false)
    
    func change () -> Void {
        if self.oldPassword.isEmpty {
            self.alert = AlertModel(title: "Ошибка", message: "Введите старый пароль.", show: true)
            return
        }
        
        if self.oldPassword.count < 6 || self.newPassword.count < 6 || self.confirmNewPassword.count < 6 {
            self.alert = AlertModel(title: "Ошибка", message: "Минимальная длина пароля 6 символов.", show: true)
            return
        }
        
        if self.newPassword.isEmpty {
            self.alert = AlertModel(title: "Ошибка", message: "Введите новый пароль.", show: true)
            return
        }
        
        if self.confirmNewPassword.isEmpty {
            self.alert = AlertModel(title: "Ошибка", message: "Подтвердите новый пароль.", show: true)
            return
        }
        
        if self.newPassword != self.confirmNewPassword {
            self.alert = AlertModel(title: "Ошибка", message: "Пароли не совпадают", show: true)
            return
        }
        
        self.load = true
        
        self.compare { status in
            if status {
                
                let url = URL(string: "\(API_URL)\(API_CHANGE_PASSWORD)")!
                let body: [String: String] = [
                    "oldPassword": self.oldPassword.toBase64(),
                    "newPassword": self.newPassword.toBase64()
                ]
                
                guard let request = Request(url: url, httpMethod: "PATCH", body: body) else {return}
                
                URLSession.shared.dataTask(with: request) {data, response, _ in
                    
                    guard let response = response as? HTTPURLResponse else {return}
                    
                    if response.statusCode == 200 {
                        guard let data = data else { return }
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {return}
                        print(json)
                        DispatchQueue.main.async {
                            self.load = false
                            self.alert = AlertModel(title: "Успех", message: "Пароль успешно изменен.", show: true)
                            self.oldPassword = ""
                            self.newPassword = ""
                            self.confirmNewPassword = ""
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.load = false
                            self.alert = AlertModel(title: "Ошибка", message: "Проверьте введенные данные и попробуйте еще раз.", show: true)
                        }
                    }
                    
                }.resume()
            } else {
                self.load = false
                self.alert = AlertModel(title: "Ошибка", message: "Вы ввели не верный текущий пароль.", show: true)
                return
            }
        }
    }
    
    func compare (completion: @escaping (Bool) -> Void) -> Void {
        
        let url = URL(string: "\(API_URL)\(API_COMPARE_OLD_PASSWORD)")!
        let body: [String: String] = [
            "password": self.oldPassword.toBase64(),
        ]
        
        guard let request = Request(url: url, httpMethod: "POST", body: body) else {return}
        
        URLSession.shared.dataTask(with: request) {_, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
        }.resume()
    }
}
