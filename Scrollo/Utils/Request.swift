//
//  Request.swift
//  Scrollo
//
//  Created by Artem Strelnik on 23.09.2022.
//

import SwiftUI
import PhotosUI

func Request (url: URL, httpMethod: String, body: [String: Any]?) -> URLRequest? {
    let token = UserDefaults.standard.string(forKey: "token")
    
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    if let token = token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let body = body {
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
    }
    
    return request
}

func MultipartRequest (url: URL, httpMethod: String, parameters: [String: Any]?) -> URLRequest? {
    let token = UserDefaults.standard.string(forKey: "token")
    let boundary = "Boundary----\(NSUUID().uuidString)"
    let body: NSMutableData = NSMutableData()
    
    guard let parameters = parameters else {return nil}
    
    for (key, value) in parameters {
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition:form-data; name=\"\(String(describing: key))\"\r\n\r\n")
        body.appendString("\(String(describing: value))\r\n")
    }
    
    body.appendString("--".appending(boundary.appending("--")))
    
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    if let token = token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    request.setValue("multipart/form-data; charset=UTF-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpBody = body as Data
    
    return request
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "imagefile.jpg"
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}

struct MultipartMedia {
    var key: String
    var filename: String
    var data: Data
    var mimeType: String
}

func createDataBody(withParameters params: [String: String]?, media: [MultipartMedia]?, boundary: String) -> Data {
   let lineBreak = "\r\n"
   var body = Data()
   if let parameters = params {
      for (key, value) in parameters {
         body.append("--\(boundary + lineBreak)")
         body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
         body.append("\(value as! String + lineBreak)")
      }
   }
   if let media = media {
      for photo in media {
         body.append("--\(boundary + lineBreak)")
         body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
         body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
         body.append(photo.data)
         body.append(lineBreak)
      }
   }
   body.append("--\(boundary)--\(lineBreak)")
   return body
}

func generateBoundary() -> String {
   return "Boundary-\(NSUUID().uuidString)"
}
