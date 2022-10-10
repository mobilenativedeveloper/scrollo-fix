//
//  AccountViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI

class AccountViewModel: ObservableObject {
    @Published var load: Bool = false
    @Published var accessPhoneBook: Bool = false
    @Published var userAccountType : Bool = false
    
    func switchUserType() -> Void {
        self.load = true
        let url = URL(string: "\(API_URL)\(API_USER_SWITCH_TYPE)")!
        
        let data: [String: String] = ["type": !self.userAccountType ? "CLOSED" : "OPEN"]
        
        guard let request = Request(url: url, httpMethod: "PATCH", body: data) else {return}
        
        
        URLSession.shared.dataTask(with: request){data, response, error in
            if let _ = error {return}

            guard let response = response as? HTTPURLResponse else {return}

            if response.statusCode == 200 {
                if let json = try? JSONDecoder().decode(UserModel.User.self, from: data!) {
                    DispatchQueue.main.async {
                        self.load = false
                    }
                }
            }
        }.resume()
    }
}
