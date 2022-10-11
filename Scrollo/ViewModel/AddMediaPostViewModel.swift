//
//  AddMediaPostViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI
import Photos
import AVKit
import Foundation
import UIKit


class AddMediaPostViewModel: ObservableObject {
    @Published var library_status: LibraryStatus = LibraryStatus.denied
    @Published var loadImages: Bool = false
    
    @Published var allPhotos: [[Asset]] = []
    
    @Published var multiply: Bool = false
    
    @Published var pickedPhoto: [Asset] = []
    @Published var selection: Asset? = nil
    
    @Published var content: String = ""
    
    @Published var alert: AlertModel = AlertModel(title: "", message: "", show: false)
    
    @Published var isPublished: Bool = false
    
    private var uploadFiles: [MultipartMedia] = []
    
    func permissions () -> Void {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self](status) in
            
            DispatchQueue.main.async {
                switch status {
                    case .denied: self.library_status = .denied
                    case .authorized:
                        self.library_status = .approved
                        if self.allPhotos.isEmpty {
                            self.getPhotoLibrary()
                        }
                    case .limited:
                        self.library_status = .limited
                        if self.allPhotos.isEmpty {
                            self.getPhotoLibrary()
                        }
                    default: self.library_status = .denied
                }
            }
        }
    }
    
    func getPhotoLibrary () -> Void {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false
        
        let library = PHAsset.fetchAssets(with: options)
        var imageStack: [Asset] = []
        
        library.enumerateObjects {[self] (asset, index, _) in
            getImageFromAsset(asset: asset) { (image) in
                imageStack.append(Asset(asset: asset, image: image))
                
                if imageStack.count == 3 {
                    self.allPhotos.append(imageStack)
                    imageStack.removeAll()
                }
                
                if index == library.count - 1 {
                    DispatchQueue.main.async {
                        self.pickedPhoto.append(self.allPhotos[0][0])
                        self.selection = self.allPhotos[0][0]
                        self.loadImages = true
                    }
                }
            }
        }
         
    }
    
    
    func getImageFromAsset (asset: PHAsset, completion: @escaping(UIImage) -> ()) -> Void {
        
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = false
        
        let size = CGSize(width: 600, height: 600)
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { image, _ in
            
            guard let resizedImage = image else {return}
            completion(resizedImage)
        }
    }
    
    func requestAVAsset(asset: PHAsset)-> AVAsset? {
            guard asset.mediaType == .video else { return nil }
            let phVideoOptions = PHVideoRequestOptions()
            phVideoOptions.version = .original
            let group = DispatchGroup()
            let imageManager = PHImageManager.default()
            var avAsset: AVAsset?
        
            group.enter()
            imageManager.requestAVAsset(forVideo: asset, options: phVideoOptions) { (asset, _, _) in
                
                avAsset = asset
                group.leave()
                
            }
            group.wait()
            
            return avAsset
    }
    
    

    func postCreationStart (content: String, files: [PostCreationStartFileModel], completed: @escaping (PostCreationStartResponse?) -> Void) {
       
        
        var filesArray: [[String: Any]] = []
        
        files.forEach { file in
            let arr = [
                "size": file.size,
                "fileName": file.fileName,
                "contentType": file.contentType,
                "identificator": file.identificator
            ] as [String : Any]
            filesArray.append(arr)
        }
        
        let data: [String : Any] = ["content": content, "files":filesArray]
        
        guard let url = URL(string: "\(API_URL)\(API_POST_CREATION_START)") else {return}


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, _ in

            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}

            if response.statusCode == 201 {
                guard let responseJson = try? JSONDecoder().decode(PostCreationStartResponse.self, from: data) else {return}
                DispatchQueue.main.async {
                    completed(responseJson)
                }
            } else {
                print("postCreationStart Error")
            }
        }.resume()
    }
    
    func loadPart (postCreationFileId: String, bytesInBase: String, completion: @escaping (Bool?) -> Void) {
        guard let url = URL(string: "\(API_URL)\(API_POST_CREATION_LOAD_PART)") else { return }
        guard let request = Request(url: url, httpMethod: "POST", body: ["postCreationFileId": postCreationFileId, "bytesInBase": bytesInBase]) else { return }
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else {return}
            
            
            if response.statusCode == 201 {
                guard let responseJson = try? JSONDecoder().decode(PostCreationStartResponse.PostCreationStartFileResponse.self, from: data) else {return}
                DispatchQueue.main.async {
                    completion(responseJson.state == "FINISHED")
                }
            } else {
                if let log = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("LOG")
                    print(log)
                }
            }
        }.resume()
    }
    
    func publish (completion: @escaping (PostModel?) -> Void) -> Void {
        self.isPublished = true
        
        var refs: [PostCreationStartFileModel] = []
        
        for photo in self.pickedPhoto {
            guard let image = photo.image.jpegData(compressionQuality: 0.7) else {return}
            
            let size = Double(Int64(image.count)) / 1024
            refs.append(PostCreationStartFileModel(image: image, size: size, fileName: "\(randomString(length: 12)).jpeg", contentType: "image/jpeg", identificator: 0))
        }
        self.postCreationStart(content: self.content, files: refs, completed: {response in
            if let response = response {
                let start = response.files
                let files = refs

                for (index, file) in start.enumerated() {
                    let chunks = getChunkData(data: files[index].image, part: file.parts)
                    for (_, chunk) in chunks.enumerated() {
                        if !chunk.base64EncodedString().isEmpty {
                            if file.parts != file.loadedParts {
                                self.loadPart(postCreationFileId: file.id, bytesInBase: chunk.base64EncodedString(), completion: {state in
                                    print("loadPart")
                                    if state == true && index == start.count - 1 {
                                        DispatchQueue.main.async {
                                            self.isPublished = false
                                            completion(nil)
                                            
                                            NotificationCenter.default.post(name: NSNotification.Name("publish.media.post"), object: nil, userInfo: [
                                                "image": UIImage(data: self.pickedPhoto[0].image.jpegData(compressionQuality: 0.7)!)!
                                            ])
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
    }
}

func getChunkData (data: Data, part: Int) -> [Data] {
    let dataLen = data.count
    let chunkSize = dataLen / part
    let fullChunks = Int(dataLen / chunkSize)
    let totalChunks = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)

    var chunks:[Data] = [Data]()
    for chunkCounter in 0..<totalChunks {
        var chunk:Data
        let chunkBase = chunkCounter * chunkSize
        var diff = chunkSize
        if(chunkCounter == totalChunks - 1) {
            diff = dataLen - chunkBase
        }

        let range = chunkBase..<(chunkBase + diff)

        chunk = data.subdata(in: range)
        chunks.append(chunk)
    }
    return chunks
}

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}


struct UploadFileStack {
    var filename: String
    var data: Data
    var size: String
}
struct PostCreationStartModel: Codable {
    var content: String
    var files: [PostCreationStartFileModel]
}

struct PostCreationStartFileModel: Codable {
    var image: Data
    var size: Double
    var fileName: String
    var contentType: String
    var identificator: Int
}

struct PostCreationStartResponse: Decodable {
    var id: String
    var content: String
    var files: [PostCreationStartFileResponse]
    
    enum CodingKeys: CodingKey {
        case id
        case files
        case content
    }
    
    struct PostCreationStartFileResponse: Decodable {
        var id: String
        var path: String
        var size: Int
        var parts: Int
        var loadedParts: Int
        var state: String
        var identificator: Int
        
        enum CodingKeys: CodingKey {
            case id
            case path
            case size
            case parts
            case loadedParts
            case state
            case identificator
        }
    }
}

