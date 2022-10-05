//
//  AddStoryViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 04.10.2022.
//

import SwiftUI
import Photos


class AddStoryViewModel : ObservableObject {
    @Published var loadAlbums: Bool = false
    @Published var loadAssets: Bool = false
    @Published var albums: [PHAssetCollection] = []
    @Published var selectedAlbum: Int = 0
    @Published var assets: [AssetModel] = []
    
    init () {
        getAlbums()
    }
    
    func getAlbums () -> Void {
        print("fetch albums")
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
        
        
        self.loadAlbums.toggle()
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
        self.loadAssets = false
        self.assets = []
        let fetchOptions = PHFetchOptions()
        
        let assetsAlbum = PHAsset.fetchAssets(in: self.albums[self.selectedAlbum], options: fetchOptions)

        assetsAlbum.enumerateObjects { asset, index, _ in
            self.PHAssetToUIImage(asset: asset) { thumbnail in
                
                self.assets.append(AssetModel(asset: asset, thumbnail: thumbnail))
                
                if index == assetsAlbum.count - 1 {
                    self.loadAssets = true
                }
            }
        }
    }
}
