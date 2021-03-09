//
//  ViewController.swift
//  CaMat
//
//  Created by Wangyiwei on 2020/2/19.
//  Copyright © 2020 Wangyiwei. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var sizesel: UISegmentedControl!
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var camsel: UISegmentedControl!
    @IBOutlet weak var freeText: UILabel!
    @IBOutlet weak var c3: UILabel!
    @IBOutlet weak var c2: UILabel!
    @IBOutlet weak var c1: UILabel!
    @IBOutlet weak var b3: UILabel!
    @IBOutlet weak var b2: UILabel!
    @IBOutlet weak var b1: UILabel!
    @IBOutlet weak var a3: UILabel!
    @IBOutlet weak var a2: UILabel!
    @IBOutlet weak var a1: UILabel!
    @IBOutlet weak var devInfo: UILabel!
    var buffer: [[Float]] = [
        [0,0,0],
        [0,0,0],
        [0,0,0]
    ]
    var into = 0
    
    let vdFront = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
    let vdBack = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
    var videoCapture: VideoCapture!
    
    @IBAction func onSizeChg(_ sender: UISegmentedControl) {
        videoCapture.stopCapturing()
        clearUI()
        switch sender.selectedSegmentIndex {
        case 0:
            videoCapture.changePreset(.vga640x480)
        case 1:
            videoCapture.changePreset(.iFrame960x540)
        case 2:
            videoCapture.changePreset(.hd1280x720)
        case 3:
            videoCapture.changePreset(.hd1920x1080)
        case 4:
            videoCapture.changePreset(.hd4K3840x2160)
        case 5:
            videoCapture.changePreset(.photo)
        default:
            break
        }
        videoCapture.startCapturing()
    }
    
    @IBAction func onSelect(_ sender: UISegmentedControl) {
        //TODO
        videoCapture.stopCapturing()
        clearUI()
        let id = sender.selectedSegmentIndex
        if(id < vdFront.devices.count) {
            videoCapture.videoDevice = vdFront.devices[id]
        } else {
            videoCapture.videoDevice = vdBack.devices[id - vdFront.devices.count]
        }
        //print(videoCapture.videoDevice.debugDescription)
        videoCapture.startCapturing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let isSupport = videoCapture.isIntrinsicSupported()
        /*switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            break;
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {(success) in
                if(!success) {
                    DispatchQueue.main.async {
                        self.clearUI()
                    }
                    return
                }
            })
            break
        default:
            self.clearUI()
            return
        }*/
        
        //MARK: IAP check
        freeText.frame = camsel.frame
        
        //end: IAP
        
        clearUI()
        
        videoCapture = VideoCapture()
        
        print(vdFront.devices.count)
        print(vdBack.devices.count)
        
        devInfo.text = UIDevice.modelName + " @ iOS " + UIDevice.current.systemVersion
        
        var cameras = vdFront.devices.count + vdBack.devices.count
        while(cameras > 2) {
            cameras -= 1
            camsel.insertSegment(withTitle: nil, at: 0, animated: false)
        }
        var i = 0
        for (id, _) in vdFront.devices.enumerated() {
            camsel.setTitle("Front\(id)", forSegmentAt: i)
            i += 1
        }
        for (id, _) in vdBack.devices.enumerated() {
            camsel.setTitle("Back\(id)", forSegmentAt: i)
            i += 1
        }
        
        let matUI = [
            [a1, a2, a3],
            [b1, b2, b3],
            [c1, c2, c3]
        ]
        
        for i in 0...2 {
            for j in 0...2 {
                matUI[i][j]?.text = "0.0"
            }
        }
        
        videoCapture.matHandler = {mat in
            for i in 0...2 {
                for j in 0...2 {
                    self.buffer[i][j] = self.buffer[i][j] * 9 / 10 + mat[i][j] / 10
                    //matUI[i][j]?.text = String(Float(Int(mat[i][j] * 100)) / 100)
                    if(self.into % 3 == 0) {
                        let v = Float(Int(self.buffer[i][j] * 100)) / 100
                        matUI[i][j]?.text = String(v)
                    }
                }
            }
            self.into += 1
            if(self.into == 10) {self.into = 0}
        }
        self.onSelect(camsel)
        
        aboutBtn.layer.cornerRadius = aboutBtn.frame.height / 4
    }
    
    func clearUI() {
        let matUI = [
            [a1, a2, a3],
            [b1, b2, b3],
            [c1, c2, c3]
        ]
        
        for i in 0...2 {
            for j in 0...2 {
                matUI[i][j]?.text = "0.0"
            }
        }
    }
}

class VideoCapture:NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSession = AVCaptureSession()
    private var videoConnection: AVCaptureConnection!
    public var matHandler: (([[Float]]) -> Void)?
    public var videoDevice: AVCaptureDevice!
    
    public func changePreset(_ preset: AVCaptureSession.Preset) {
        if(captureSession.canSetSessionPreset(preset)) {
            captureSession.sessionPreset = preset
        }
    }
    
    override init(){
        
        super.init()
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720
        // Input
        //let videoDevice = AVCaptureDevice.default(for: .video)
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let videoDevice = videoDevice else {return}
        let videoDeviceInput = try! AVCaptureDeviceInput(device: videoDevice)
        guard captureSession.canAddInput(videoDeviceInput) else { fatalError() }
        captureSession.addInput(videoDeviceInput)
        //videoDevice?.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 5)
        
        // Output
        let videoDataOutput = AVCaptureVideoDataOutput()
        do {
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            // videoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
            guard captureSession.canAddOutput(videoDataOutput) else {
                fatalError()
            }
            captureSession.addOutput(videoDataOutput)
        }
        
        // Connection
        videoConnection = videoDataOutput.connection(with: .video)!
        videoConnection.videoOrientation = .portrait
        
        if #available(iOS 11.0, *),  videoConnection.isCameraIntrinsicMatrixDeliverySupported {
            // Enable Intrinsic parameter
            videoConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            print("Intrinsic Matrix is supported :)" )
        } else {
            print("Intrinsic Matrix is NOT supported :(")
        }
        captureSession.commitConfiguration()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard connection == videoConnection else { fatalError() }
        guard let imagePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { fatalError() }
        
        // get intrinsic param from each captured image.
        CVPixelBufferLockBaseAddress(imagePixelBuffer, [])
        var matrix:matrix_float3x3?
        if #available(iOS 11.0, *), let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) as? Data {
            matrix = camData.withUnsafeBytes { $0.pointee }
        }
        
        CVPixelBufferUnlockBaseAddress(imagePixelBuffer,[])
        
        let (c1, c2, c3) = matrix!.columns
        DispatchQueue.main.async {
            self.matHandler?([
                [c1.x, c1.y, c1.z],
                [c2.x, c2.y, c2.z],
                [c3.x, c3.y, c3.z]
            ])
        }
        //print(matrix)
    }
    
    // start and stop capturing
    func isCaptureRunning()->Bool{
        return self.captureSession.isRunning
    }
    func startCapturing(){
        if(!self.captureSession.isRunning){
            self.captureSession.startRunning()
        }
    }
    func stopCapturing(){
        if(self.captureSession.isRunning){
            self.captureSession.stopRunning()
        }
    }
    
    // return intrinsic is supported or not.
    func isIntrinsicSupported() -> String {
        if #available(iOS 11.0, *) {
            if videoConnection!.isCameraIntrinsicMatrixDeliverySupported {
                return "Intrinsic param is supported."
            } else {
                return "Intrinsic param is NOT supported."
            }
        } else {
            return "iOS version is lower than 11.0."
        }
    }
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
