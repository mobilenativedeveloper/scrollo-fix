//
//  AssetModel.swift
//  Scrollo
//
//  Created by Artem Strelnik on 04.10.2022.
//

import SwiftUI
import Photos

struct AssetModel: Identifiable {
    var id = UUID().uuidString
    var asset: PHAsset
    var thumbnail: UIImage
}
