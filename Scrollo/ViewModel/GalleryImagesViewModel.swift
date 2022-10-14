//
//  GalleryImagesViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 09.10.2022.
//

import SwiftUI
import Photos

enum LibraryStatus {
   case denied
   case approved
   case limited
}

class GalleryImagesViewModel: ObservableObject{
    @Published var library_status: LibraryStatus = LibraryStatus.denied
    @Published var loadAlbums: Bool = false
    @Published var loadAssets: Bool = false
    @Published var albums: [PHAssetCollection] = []
    @Published var selectedAlbum: Int = 0
    @Published var assets: [AssetModel] = []
    
    init(onlyPhoto: Bool){
        loadMedia(onlyPhoto: onlyPhoto)
    }
    
    func loadMedia(onlyPhoto: Bool){
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self](status) in

            DispatchQueue.main.async {
                switch status {
                    case .denied: self.library_status = .denied
                    case .authorized:
                        self.library_status = .approved
                        getAlbums(onlyPhoto: onlyPhoto)
                    case .limited:
                        self.library_status = .limited
                        getAlbums(onlyPhoto: onlyPhoto)
                    default: self.library_status = .denied
                }
            }
        }
    }
    
    func getAlbums (onlyPhoto: Bool) -> Void {
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
        self.getThumbnailAssetsFromAlbum(onlyPhoto: onlyPhoto)
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
    
    func getThumbnailAssetsFromAlbum (onlyPhoto: Bool) {
        self.loadAssets = false
        self.assets = []
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assetsAlbum = PHAsset.fetchAssets(in: self.albums[self.selectedAlbum], options: fetchOptions)
        
        assetsAlbum.enumerateObjects { asset, index, _ in
            self.PHAssetToUIImage(asset: asset) { thumbnail in
                let imageAsset: AssetModel = .init(asset: asset)
                self.assets.append(imageAsset)
                
                if index == assetsAlbum.count - 1 {
                    
                    self.loadAssets = true
                    
                }
            }
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
