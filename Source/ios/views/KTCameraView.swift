//
//  KTCameraView.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit
import AVFoundation

public enum ActiveDeviceCapturePosition {
    case back, front
}

public enum CameraOutputMode {
    case audio
    case video
    case videoSampleBuffer
    case photo
    case selfie
}

public protocol KTCameraViewDelegate: class {
    func outputModeForCameraView(_ cameraView: KTCameraView) -> CameraOutputMode
    func cameraView(_ cameraView: KTCameraView, didCaptureStillImage image: UIImage)
    func cameraView(_ cameraView: KTCameraView, didStartVideoCaptureAtURL fileURL: URL)
    func cameraView(_ cameraView: KTCameraView, didFinishVideoCaptureAtURL fileURL: URL)
    func cameraView(_ cameraView: KTCameraView, didMeasureAveragePower avgPower: Float, peakHold: Float, forAudioChannel channel: AVCaptureAudioChannel)
    func cameraView(_ cameraView: KTCameraView, didOutputMetadataFaceObject metadataFaceObject: AVMetadataFaceObject)

    func cameraViewCaptureSessionFailedToInitializeWithError(_ error: NSError)
    func cameraViewBeganAsyncStillImageCapture(_ cameraView: KTCameraView)
    func cameraViewShouldEstablishAudioSession(_ cameraView: KTCameraView) -> Bool
    func cameraViewShouldEstablishVideoSession(_ cameraView: KTCameraView) -> Bool
    func cameraViewShouldOutputFaceMetadata(_ cameraView: KTCameraView) -> Bool
    func cameraViewShouldRenderFacialRecognition(_ cameraView: KTCameraView) -> Bool
}

public class KTCameraView: UIView,
    AVCaptureVideoDataOutputSampleBufferDelegate,
    AVCaptureFileOutputRecordingDelegate,
    AVCaptureMetadataOutputObjectsDelegate {

    weak var delegate: KTCameraViewDelegate?

    fileprivate let avAudioOutputQueue = DispatchQueue(label: "api.avAudioOutputQueue", attributes: [])
    fileprivate let avCameraOutputQueue = DispatchQueue(label: "api.avCameraOutputQueue", attributes: [])
    fileprivate let avMetadataOutputQueue = DispatchQueue(label: "api.avMetadataOutputQueue", attributes: [])
    fileprivate let avVideoOutputQueue = DispatchQueue(label: "api.avVideoOutputQueue", attributes: [])

    fileprivate var captureInput: AVCaptureInput!
    fileprivate var captureSession: AVCaptureSession!

    fileprivate var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var codeDetectionLayer: CALayer!

    fileprivate var capturePreviewOrientation: AVCaptureVideoOrientation!

    fileprivate var audioDataOutput: AVCaptureAudioDataOutput!
    fileprivate var audioLevelsPollingTimer: Timer!

    fileprivate var videoDataOutput: AVCaptureVideoDataOutput!
    fileprivate var videoFileOutput: AVCaptureMovieFileOutput!

    fileprivate var stillCameraOutput: AVCaptureStillImageOutput!

    fileprivate var backCamera: AVCaptureDevice? {
        for device in AVCaptureDevice.devices(for: .video) where (device as AnyObject).position == .back {
            return device
        }
        return nil
    }

    fileprivate var frontCamera: AVCaptureDevice? {
        for device in AVCaptureDevice.devices(for: .video) where (device as AnyObject).position == .front {
            return device
        }
        return nil
    }

    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }

    fileprivate var mic: AVCaptureDevice {
        return AVCaptureDevice.default(for: .audio)!
    }

    fileprivate var outputFaceMetadata: Bool {
        return delegate?.cameraViewShouldOutputFaceMetadata(self) ?? false
    }

    fileprivate var recording = false {
        didSet {
            if recording == true {
                startAudioLevelsPollingTimer()
            } else {
                stopAudioLevelsPollingTimer()
            }
        }
    }

    fileprivate var renderFacialRecognition: Bool {
        return delegate?.cameraViewShouldRenderFacialRecognition(self) ?? false
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        isOpaque = false
        backgroundColor = UIColor.clear
    }

    fileprivate func configureAudioSession() {
        guard let delegate = delegate else { return }

        if delegate.cameraViewShouldEstablishAudioSession(self) {
            do {
                let input = try AVCaptureDeviceInput(device: mic)
                captureSession.addInput(input)

                audioDataOutput = AVCaptureAudioDataOutput()
                if captureSession.canAddOutput(audioDataOutput) {
                    captureSession.addOutput(audioDataOutput)
                }
            } catch let error as NSError {
                logWarn(error.localizedDescription)
            }
        }
    }

    fileprivate func configureFacialRecognition() {
        if outputFaceMetadata {
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: avMetadataOutputQueue)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        }

        if renderFacialRecognition {
            codeDetectionLayer = CALayer()
            codeDetectionLayer.frame = bounds
            layer.insertSublayer(codeDetectionLayer, above: capturePreviewLayer)
        }
    }

    fileprivate func configurePhotoSession() {
        stillCameraOutput = AVCaptureStillImageOutput()
        if captureSession.canAddOutput(stillCameraOutput) {
            captureSession.addOutput(stillCameraOutput)
        }
    }

    fileprivate func configureVideoSession() {
        if let delegate = delegate, delegate.cameraViewShouldEstablishVideoSession(self) {
            videoDataOutput = AVCaptureVideoDataOutput()
            var settings = [AnyHashable: Any]()
            settings.updateValue(NSNumber(value: kCVPixelFormatType_32BGRA as UInt32), forKey: String(kCVPixelBufferPixelFormatTypeKey))
            videoDataOutput.videoSettings = settings as! [String: Any]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.setSampleBufferDelegate(self, queue: avVideoOutputQueue)

            captureSession.addOutput(videoDataOutput)

            videoFileOutput = AVCaptureMovieFileOutput()
        }
    }

    fileprivate func startAudioLevelsPollingTimer() {
        audioLevelsPollingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KTCameraView.pollForAudioLevels), userInfo: nil, repeats: true)
        audioLevelsPollingTimer.fire()
    }

    fileprivate func stopAudioLevelsPollingTimer() {
        if let timer = audioLevelsPollingTimer {
            timer.invalidate()
            audioLevelsPollingTimer = nil
        }
    }

    func setCapturePreviewOrientationWithDeviceOrientation(_ deviceOrientation: UIDeviceOrientation, size: CGSize) {
        if let capturePreviewLayer = capturePreviewLayer {
            capturePreviewLayer.frame.size = size

            if let connection = capturePreviewLayer.connection {
                switch deviceOrientation {
                case .portrait:
                    connection.videoOrientation = .portrait
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight
                default:
                    connection.videoOrientation = .portrait
                }
            }
        }
    }

    @objc func pollForAudioLevels() {
        if audioDataOutput == nil {
            return
        }

        if audioDataOutput.connections.count > 0 {
            let connection = audioDataOutput.connections[0]
            let channels = connection.audioChannels

            for channel in channels {
                let avg = (channel as AnyObject).averagePowerLevel
                let peak = (channel as AnyObject).peakHoldLevel

                delegate?.cameraView(self, didMeasureAveragePower: avg!, peakHold: peak!, forAudioChannel: channel )
            }
        }
    }

    func startBackCameraCapture() {
        if let backCamera = backCamera {
            startCapture(backCamera)
        }
    }

    func startFrontCameraCapture() {
        if let frontCamera = frontCamera {
            startCapture(frontCamera)
        }
    }

    func startCapture(_ device: AVCaptureDevice) {
        if captureSession != nil {
            stopCapture()
        }

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined {
            NotificationCenter.default.postNotificationName("ApplicationWillRequestMediaAuthorization")
        }

        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            } else if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }

            device.unlockForConfiguration()
        } catch let error as NSError {
            logWarn(error.localizedDescription)
            delegate?.cameraViewCaptureSessionFailedToInitializeWithError(error)
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            captureSession.addInput(input)

            capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            capturePreviewLayer.frame = bounds
            capturePreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            layer.addSublayer(capturePreviewLayer)

            configureAudioSession()
            configureFacialRecognition()
            configurePhotoSession()
            configureVideoSession()

            captureSession.startRunning()
        } catch let error as NSError {
            logWarn(error.localizedDescription)
            delegate?.cameraViewCaptureSessionFailedToInitializeWithError(error)
        }
    }

    func stopCapture() {
        if let session = captureSession {
            session.stopRunning()
            captureSession = nil
        }

        if capturePreviewLayer != nil {
            capturePreviewLayer.removeFromSuperlayer()
            capturePreviewLayer = nil
        }
    }

    func capture() {
        if let mode = delegate?.outputModeForCameraView(self) {
            switch mode {
            case .audio:
                if recording == false {
                    // captureAudio()
                } else {
                    // audioFileOutput.stopRecording()
                }
            case .photo:
                captureFrame()
            case .selfie:
                captureFrame()
            case .video:
                if recording == false {
                    captureVideo()
                } else {
                    videoFileOutput.stopRecording()
                }
            case .videoSampleBuffer:
                if recording == false {
                    captureVideo()
                } else {
                    captureSession.removeOutput(videoDataOutput)
                }
            }
        }
    }

    fileprivate func captureFrame() {
        delegate?.cameraViewBeganAsyncStillImageCapture(self)

        if isSimulator() {
            if let window = UIApplication.shared.keyWindow {
                UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
                window.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                delegate?.cameraView(self, didCaptureStillImage: image!)
            }
            return
        }

        avCameraOutputQueue.async {
            if let cameraOutput = self.stillCameraOutput, let connection = cameraOutput.connection(with: AVMediaType.video) {
                if let videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) {
                    connection.videoOrientation = videoOrientation
                }

                cameraOutput.captureStillImageAsynchronously(from: connection) { imageDataSampleBuffer, error in
                    if error == nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)

                        if let image = UIImage(data: imageData!) {
                            self.delegate?.cameraView(self, didCaptureStillImage: image)
                        }
                    } else {
                        logWarn("Error capturing still image \(error!)")
                    }
                }
            }
        }
    }

    fileprivate func captureVideo() {
        if isSimulator() {
            return
        }

        if let mode = delegate?.outputModeForCameraView(self) {
            switch mode {
            case .video:
                if captureSession.canAddOutput(videoFileOutput) {
                    captureSession.addOutput(videoFileOutput)
                }

                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let outputFileURL = URL(fileURLWithPath: "\(paths.first!)/\(Date().timeIntervalSince1970).m4v")
                videoFileOutput.startRecording(to: outputFileURL, recordingDelegate: self)
            case .videoSampleBuffer:
                if captureSession.canAddOutput(videoDataOutput) {
                    captureSession.addOutput(videoDataOutput)
                }
            default:
                break
            }
        }
    }

    // MARK: AVCaptureFileOutputRecordingDelegate

    public func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        recording = true

        delegate?.cameraView(self, didStartVideoCaptureAtURL: fileURL)
    }

    public func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        recording = false

        delegate?.cameraView(self, didFinishVideoCaptureAtURL: outputFileURL)
        captureSession.removeOutput(videoFileOutput)
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    public func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //println("dropped samples \(sampleBuffer)")
    }

    public func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        // CVPixelBufferLockBaseAddress(imageBuffer, 0)
        //
        // let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        // let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        // let width = CVPixelBufferGetWidth(imageBuffer)
        // let height = CVPixelBufferGetHeight(imageBuffer)
        //
        // let colorSpace = CGColorSpaceCreateDeviceRGB()!
        // let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue).rawValue
        // let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        //
        // let quartzImage = CGBitmapContextCreateImage(context)!
        // CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
        //
        // let frame = UIImage(CGImage: quartzImage)
    }

    // MARK: AVCaptureMetadataOutputObjectsDelegate

    public func metadataOutput(captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for object in metadataObjects {
            if let metadataFaceObject = object as? AVMetadataFaceObject {
                let detectedFace = capturePreviewLayer.transformedMetadataObject(for: metadataFaceObject)
                delegate?.cameraView(self, didOutputMetadataFaceObject: detectedFace as! AVMetadataFaceObject)
            }
        }

        if renderFacialRecognition {
            DispatchQueue.main.async {
                self.clearDetectedMetadataObjects()
                self.showDetectedMetadataObjects(metadataObjects)
            }
        }
    }

    fileprivate func clearDetectedMetadataObjects() {
        if let codeDetectionLayer = codeDetectionLayer {
            codeDetectionLayer.sublayers = nil
        }
    }

    fileprivate func showDetectedMetadataObjects(_ metadataObjects: [Any]!) {
        for object in metadataObjects {
            if let metadataFaceObject = object as? AVMetadataFaceObject, let detectedCode = capturePreviewLayer.transformedMetadataObject(for: metadataFaceObject) as? AVMetadataFaceObject {
                let shapeLayer = CAShapeLayer()
                shapeLayer.strokeColor = UIColor.green.cgColor
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.lineWidth = 1.0
                shapeLayer.lineJoin = kCALineJoinRound
                shapeLayer.path = UIBezierPath(rect: detectedCode.bounds).cgPath
                codeDetectionLayer.addSublayer(shapeLayer)
            }
        }
    }
}
