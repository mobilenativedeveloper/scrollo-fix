//
//  SearchViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 10.10.2022.
//

import SwiftUI
import Combine

struct ImageModel: Identifiable, Codable, Hashable {
    var id: String
    var download_url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case download_url
    }
}

class SearchViewModel : ObservableObject {
    @Published var searchText : String = String()
    @Published private (set) var users: [UserModel.User] = []
    @Published var images : [ImageModel]?
    @Published var currentPage: Int = 0
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    
    var subscription: Set<AnyCancellable> = []
    
    init () {
        $searchText
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ (string) -> String? in
                if string.count < 1 {
                    self.users = []
                    return nil
                }
                return string
            })
            .compactMap{ $0 }
            .sink { (_) in
                //
            } receiveValue: { [self] (searchField) in
                search(searchText: searchField)
            }.store(in: &subscription)
        
        updateImages()
    }
    
    func search(searchText: String) -> Void {
        guard let url = URL(string: "\(API_URL)\(API_USER_FIND)\(searchText)?page=0&pageSize=100") else {
            self.users = []
            return
        }
        if let request = Request(url: url, httpMethod: "GET", body: nil) {
            URLSession.shared.dataTask(with: request) {data, response, error in
                if let _ = error { return }
                
                guard let response = response as? HTTPURLResponse else { return }
                
                if response.statusCode == 200 {
                    if let json = try? JSONDecoder().decode(UserSearchResponse.self, from: data!) {
                        DispatchQueue.main.async {
                            print(json.data)
                            self.users = json.data
                        }
                    }
                }
            }.resume()
        }
    }
    
    func updateImages () {
        currentPage += 1
        fetchImages()
    }
    
    func fetchImages () {
        
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(currentPage)&limit=12") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {data, _, error in
            if let _ = error { return }
            
            guard let json = try? JSONDecoder().decode([ImageModel].self, from: data!) else { return }
            let compactImages = json.compactMap({item -> ImageModel? in
                let imageId = item.id
                let SizedURL = "https://picsum.photos/id/\(imageId)/300/300"
                return .init(id: imageId, download_url: SizedURL)
            })
            
            DispatchQueue.main.async {
                if self.images == nil { self.images = [] }
                self.images?.append(contentsOf: compactImages)
                self.endPagination = (self.images?.count ?? 0) > 100
                self.startPagination = false
            }
        }.resume()
    }
}
