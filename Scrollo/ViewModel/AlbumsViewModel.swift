//
//  AlbumsViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI

class AlbumsViewModel: ObservableObject {
    @Published var albums: [AlbumModel] = []
    @Published var albumsComposition: [[AlbumModel]] = []
    @Published var status: AlbumStatus = .initial
    
    @Published var page = 0
    @Published var pageSize = 5
    
    
    init (composition: Bool = false) {
        getAlbums(composition: composition)
    }
    
    func getAlbums (composition: Bool) {
        
        guard let url = URL(string: "\(API_URL)\(API_SAVED_ALBUM)?page=\(page)&pageSize=\(pageSize)") else { return }
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else { return }
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let responseJson = try? JSONDecoder().decode(AlbumListResponseModel.self, from: data) else {return}
                
                DispatchQueue.main.async {
                    self.albums = responseJson.data
                    if composition {
                        self.createCompositionLayoutAlbums()
                    }
                    self.status = AlbumStatus.success
                }
            }
        }.resume()
    }
    
    func createCompositionLayoutAlbums () {
        var albumsCompositionLayout: [[AlbumModel]] = []
        var stack: [AlbumModel] = []
        
        self.albums.forEach { album in
            stack.append(album)
            
            if stack.count == 2 || stack[0].id == self.albums[self.albums.count - 1].id {
                albumsCompositionLayout.append(stack)
                stack.removeAll()
            }
        }
        
        self.albumsComposition = albumsCompositionLayout
    }
}

