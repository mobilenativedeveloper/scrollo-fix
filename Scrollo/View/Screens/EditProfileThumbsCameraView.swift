//
//  EditProfileThumbsCameraView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 11.10.2022.
//

import SwiftUI
import AVFoundation

struct EditProfileThumbsCameraView: View {
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var cameraController: CameraController = CameraController()
    
    @State var didTapCapture: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle.xmark.black")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fill)
                }
                Spacer(minLength: 0)
                Text("Фото")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#2E313C"))
                Spacer(minLength: 0)
                Button(action: {
                    
                }) {
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal)
            
            GeometryReader {proxy in
                
                let size = proxy.size
                CustomCameraRepresentable(image: self.$image, didTapCapture: $didTapCapture, size: size)
                
            }
            .frame(height: screen_rect.height / 2)
            .background(Color.black)
            .padding(.top)
            .overlay(
                Button(action: {
                    cameraController.flip()
                }) {
                    Image("flip.camera")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 32)
                .padding(.bottom, 32)
                ,alignment: .bottomLeading
            )
            .overlay(
                Button(action: {
                    cameraController.flash.toggle()
                }) {
                    Image("flash")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.trailing, 32)
                .padding(.bottom, 32)
                ,alignment: .bottomTrailing
            )
            
            Spacer(minLength: 0)
            
            Button(action: {
                
            }){
                Circle()
                    .fill(Color(hex: "#cdcdcd"))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                    )
                
            }
            
            Spacer(minLength: 0)
            
        }
        .onAppear(perform: cameraController.permission)
    }
}

struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        
        if(self.didTapCapture) {
            cameraViewController.didTapRecord()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CustomCameraRepresentable
        
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
            parent.didTapCapture = false
            
            if let imageData = photo.fileDataRepresentation() {
                parent.image = UIImage(data: imageData)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class CustomCameraController: UIViewController {
    
    var image: UIImage?
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var size: CGSize
    
    //DELEGATE
    var delegate: AVCapturePhotoCaptureDelegate?
    
    func didTapRecord() {
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: AVCaptureDevice.Position.unspecified)
        for device in deviceDiscoverySession.devices {
            
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }
        
        self.currentCamera = self.backCamera
    }
    
    
    func setupInputOutput() {
        do {
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
        
    }
    func setupPreviewLayer()
    {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = size
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
}
