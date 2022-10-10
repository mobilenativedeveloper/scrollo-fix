//
//  AttachmentsViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 10.10.2022.
//

import SwiftUI

import SwiftUI
import Photos
import AVKit
import Foundation

enum PermissionStatus {
    case denied
    case approved
    case limited
}

class AttachmentsViewModel: ObservableObject{
    
    @Published var permissionStatus: PermissionStatus = .denied
    
    @Published var albums: [PHAssetCollection] = []
    
    @Published var selectedAlbum: Int = 0
    
    @Published var assets: [AssetModel] = []
    
    @Published var selectedPhotos: [AssetModel] = []
    
    @Published var albumPresent: Bool = false
    
    var load: Bool = false
    
    
    init(){
        requestPermission()
    }
   
    func requestPermission()->Void{
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[self](status) in
            DispatchQueue.main.async {
                switch status {
                case .denied:
                    print("denide")
                    self.permissionStatus = .denied
                case .authorized:
                    print("authorized")
                    self.permissionStatus = .approved
                    getAlbums()
                case .limited:
                    print("limited")
                    self.permissionStatus = .limited
                default:
                    self.permissionStatus = .denied
                    print("denied")
                }
            }
        }
    }
    
    func openAppSettings(){
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func getAlbums () -> Void {
        let fetchOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        smartAlbums.enumerateObjects { (assetCollection, index, stop) in
            if assetCollection.localizedTitle == "Recents" {
                self.albums.append(assetCollection)
            }
        }

        userAlbums.enumerateObjects { [self](assetCollection, index, stop) in
            self.albums.append(assetCollection)
        }

        self.getThumbnailAssetsFromAlbum()
    }
    
    func PHAssetToUIImage (asset: PHAsset, completion: @escaping(UIImage) -> ()) -> Void {
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
    
    func getVideoDuration (asset: AssetModel) -> String {
        let seconds = asset.asset.duration
        let (_,  minf) = modf(seconds / 3600)
        let (min, secf) = modf(60 * minf)
        return "\(Int(min)):\(Int(60 * secf))"
    }
    
    func getThumbnailAssetsFromAlbum () {
        self.load = false
        self.assets = []
        let fetchOptions = PHFetchOptions()
        
        let assetsAlbum = PHAsset.fetchAssets(in: self.albums[self.selectedAlbum], options: fetchOptions)

        assetsAlbum.enumerateObjects { asset, index, _ in
            self.PHAssetToUIImage(asset: asset) { thumbnail in
                
                self.assets.append(AssetModel(asset: asset, thumbnail: thumbnail))
                
                if index == assetsAlbum.count - 1 {
                    self.load = true
                    if self.albumPresent {
                        withAnimation(.easeInOut){
                            self.albumPresent = false
                        }
                    }
                }
            }
        }
    }
    
    func pickPhoto(asset: AssetModel)->Void{
        if let index = self.selectedPhotos.firstIndex(where: {$0.id == asset.id}) {
            self.selectedPhotos.remove(at: index)
        }
        else{
            self.selectedPhotos.append(asset)
        }
    }
    
    func getNumber (asset: AssetModel) -> Int {
        
        if let index = self.selectedPhotos.firstIndex(where: { $0.id == asset.id}) {
            
            return index + 1
        } else {
            
            return -1
        }
    }
    
    func checkSelect (asset: AssetModel) -> Bool {
        
        if let _ = self.selectedPhotos.firstIndex(where: { $0.id == asset.id}) {
            
            return true
        } else {
            
            return false
        }
    }
    
    func getAlbumTitle (album: PHAssetCollection) -> String {
        switch album.localizedTitle?.lowercased() {
            case "recents":
                return "Недавние"
            default:
                return album.localizedTitle!
        }
    }
    
    func getCountMediaInAlbum (album: PHAssetCollection) -> Int{
        let fetchOptions = PHFetchOptions()
        
        let assetsAlbum = PHAsset.fetchAssets(in: album, options: fetchOptions)
        return assetsAlbum.count
    }
    
    
}
