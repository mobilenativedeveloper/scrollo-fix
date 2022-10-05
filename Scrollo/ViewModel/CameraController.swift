//
//  CameraController.swift
//  Scrollo
//
//  Created by Artem Strelnik on 04.10.2022.
//

import SwiftUI
import AVFoundation
import Photos
import AVKit

class CameraController: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate  {
    
//    @Published var alert: AlertModel = AlertModel(title: "", message: "", show: false)
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureMovieFileOutput ()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    
    @Published var thumbnail: UIImage?
    
    @Published var didFinishRecordingTo: Bool = false
    
    @Published var flash: Bool = false
    @Published var position: AVCaptureDevice.Position = .back
    
    func permission () -> Void {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
            case .authorized:
                beginConfiguration()
                return
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (status) in
                    if status {
                        
                        self.beginConfiguration()
                    }
                }
            case .denied:
//                self.alert = AlertModel(title: "Ошибка", message: "Нет доступа к камере", show: true)
                return
            default: return
        }
    }
    
    func beginConfiguration () -> Void {
        
        do {
            
            self.session.beginConfiguration()
            let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.position)
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput ){
                self.session.addInput(videoInput)
                self.session.addInput(audioInput)
            }
            
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
            
        } catch {
            print("CAMERA ERROR", error.localizedDescription)
        }
    }
    
    func startRecording () {
        
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        
        isRecording = true
    }
    
    func stopRecording () {
        
        output.stopRecording()
        
        isRecording = false
    }
    
    func fileOutput (_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        DispatchQueue.global().async {
            let asset = AVAsset(url: outputFileURL)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            
            let tumbnailTime = CMTimeMake(value: 7, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: tumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    self.thumbnail = thumbImage
                    self.previewURL = outputFileURL
                    self.didFinishRecordingTo = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func flip () {
        
    }
}

struct CameraPreview : UIViewRepresentable {
    
    @EnvironmentObject var cameraController : CameraController
    var size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView()
        
        cameraController.preview = AVCaptureVideoPreviewLayer(session: cameraController.session)
        cameraController.preview.frame.size = size
        
        cameraController.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraController.preview)
        
        cameraController.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
