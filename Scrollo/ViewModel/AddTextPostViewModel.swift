//
//  AddTextPostViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 03.10.2022.
//

import SwiftUI

class AddTextPostViewModel: ObservableObject {
    @Published var load: Bool = false
    @Published var content: String = ""
    @Published var error: Bool = false
    @Published var errorMessage: String = String()
    
    func publish(completion: @escaping (PostModel?) -> Void) -> Void {
        if self.content.isEmpty {
            self.errorMessage = "Введите текст публикации."
            self.error.toggle()
            return
        }
        self.load = true
        
        guard let url = URL(string: "\(API_URL)\(API_POST)") else {return}
        
        guard let request = MultipartRequest(url: url, httpMethod: "POST", parameters: ["content": self.content, "type": "TEXT"]) else {return}
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 201 {
                guard let post = try? JSONDecoder().decode(PostModel.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.load = false
                    completion(post)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Не удалось опубликовать пост, попробуйте еще раз."
                    self.error.toggle()
                }
            }
        }.resume()
    }
}
