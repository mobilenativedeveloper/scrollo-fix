//
//  VideoThumbnailViewModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 08.10.2022.
//

import SwiftUI
import AVKit

class VideoThumbnailViewModel: ObservableObject {
    @Published var load: Bool = false
    @Published var thumbnailVideo: UIImage = UIImage()
    @Published var error: Bool = false
    func createThumbnailFromVideo(url: URL) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            
            let tumbnailTime = CMTimeMake(value: 7, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: tumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    self.thumbnailVideo = thumbImage
                    self.load = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = true
                }
                print(error.localizedDescription)
            }
        }
    }
}
