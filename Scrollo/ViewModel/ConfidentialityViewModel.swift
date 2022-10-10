//
//  ConfidentialityViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI

class ConfidentialityViewModel: ObservableObject {
    
    @Published var confidentiality: ConfidentialityModel = ConfidentialityModel(writeComments: "ALL", mark: "ALL", writeMessage: "ALL")
    @Published var load: Bool = false
    @Published var alert: AlertModel = AlertModel(title: "", message: "", show: false)
    
    init () {
        if !self.load {
            self.getConfidentiality()
        }
    }
    
    func getConfidentiality () -> Void {
        
        let url = URL(string: "\(API_URL)\(API_CONFIDENTIALITY)")!
        
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                let json = try? JSONDecoder().decode(ConfidentialityModel.self, from: data!)
                
                if let json = json {
                    
                    DispatchQueue.main.async {
                        self.confidentiality = json
                        self.load = true
                    }
                }
            }
        }.resume()
    }
    
    func changeConfidentiality (body: [String: String]) -> Void {
        
        guard let url = URL(string: "\(API_URL)\(API_CONFIDENTIALITY)") else {return}
        guard let request = Request(url: url, httpMethod: "PATCH", body: body) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode != 200 {
                DispatchQueue.main.async {
                    self.alert = AlertModel(title: "Ошибка", message: "Не удалось изменить параметр.", show: true)
                }
            }
            
        }.resume()
    }
}
