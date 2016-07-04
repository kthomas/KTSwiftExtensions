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
    case Back, Front
}

public enum CameraOutputMode {
    case Audio
    case Video
    case VideoSampleBuffer
    case Photo
    case Selfie
}

public protocol KTCameraViewDelegate {
    func outputModeForCameraView(cameraView: KTCameraView) -> CameraOutputMode
    func cameraView(cameraView: KTCameraView, didCaptureStillImage image: UIImage)
    func cameraView(cameraView: KTCameraView, didStartVideoCaptureAtURL fileURL: NSURL)
    func cameraView(cameraView: KTCameraView, didFinishVideoCaptureAtURL fileURL: NSURL)
    func cameraView(cameraView: KTCameraView, didMeasureAveragePower avgPower: Float, peakHold: Float, forAudioChannel channel: AVCaptureAudioChannel)
    func cameraView(cameraView: KTCameraView, didOutputMetadataFaceObject metadataFaceObject: AVMetadataFaceObject)

    func cameraViewCaptureSessionFailedToInitializeWithError(error: NSError)
    func cameraViewBeganAsyncStillImageCapture(cameraView: KTCameraView)
    func cameraViewShouldEstablishAudioSession(cameraView: KTCameraView) -> Bool
    func cameraViewShouldEstablishVideoSession(cameraView: KTCameraView) -> Bool
    func cameraViewShouldOutputFaceMetadata(cameraView: KTCameraView) -> Bool
    func cameraViewShouldRenderFacialRecognition(cameraView: KTCameraView) -> Bool
}

public class KTCameraView: UIView,
                  AVCaptureVideoDataOutputSampleBufferDelegate,
                  AVCaptureFileOutputRecordingDelegate,
                  AVCaptureMetadataOutputObjectsDelegate {

    var delegate: KTCameraViewDelegate!

    private let avAudioOutputQueue = dispatch_queue_create("api.avAudioOutputQueue", DISPATCH_QUEUE_SERIAL)
    private let avCameraOutputQueue = dispatch_queue_create("api.avCameraOutputQueue", DISPATCH_QUEUE_SERIAL)
    private let avMetadataOutputQueue = dispatch_queue_create("api.avMetadataOutputQueue", DISPATCH_QUEUE_SERIAL)
    private let avVideoOutputQueue = dispatch_queue_create("api.avVideoOutputQueue", DISPATCH_QUEUE_SERIAL)

    private var captureInput: AVCaptureInput!
    private var captureSession: AVCaptureSession!

    private var capturePreviewLayer: AVCaptureVideoPreviewLayer!
    private var codeDetectionLayer: CALayer!

    private var capturePreviewOrientation: AVCaptureVideoOrientation!

    private var audioDataOutput: AVCaptureAudioDataOutput!
    private var audioLevelsPollingTimer: NSTimer!

    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var videoFileOutput: AVCaptureMovieFileOutput!

    private var stillCameraOutput: AVCaptureStillImageOutput!

    private var backCamera: AVCaptureDevice! {
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if device.position == .Back {
                return device as! AVCaptureDevice
            }
        }
        return nil
    }

    private var frontCamera: AVCaptureDevice! {
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if device.position == .Front {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }

    var isRunning: Bool {
        if let captureSession = captureSession {
            return captureSession.running
        }
        return false
    }

    private var mic: AVCaptureDevice! {
        get {
            return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        }
    }

    private var outputFaceMetadata: Bool {
        if let delegate = delegate {
            return delegate.cameraViewShouldOutputFaceMetadata(self)
        }
        return false
    }

    private var recording = false {
        didSet {
            if recording == true {
                startAudioLevelsPollingTimer()
            } else {
                stopAudioLevelsPollingTimer()
            }
        }
    }

    private var renderFacialRecognition: Bool {
        if let delegate = delegate {
            return delegate.cameraViewShouldRenderFacialRecognition(self)
        }
        return false
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        opaque = false
        backgroundColor = UIColor.clearColor()
    }

    private func configureAudioSession() {
        if let delegate = delegate {
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
    }

    private func configureFacialRecognition() {
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

    private func configurePhotoSession() {
        stillCameraOutput = AVCaptureStillImageOutput()
        if captureSession.canAddOutput(stillCameraOutput) {
            captureSession.addOutput(stillCameraOutput)
        }
    }

    private func configureVideoSession() {
        if let delegate = delegate {
            if delegate.cameraViewShouldEstablishVideoSession(self) {
                videoDataOutput = AVCaptureVideoDataOutput()
                var settings = [NSObject: AnyObject]()
                settings.updateValue(NSNumber(unsignedInt: kCVPixelFormatType_32BGRA), forKey: String(kCVPixelBufferPixelFormatTypeKey))
                videoDataOutput.videoSettings = settings
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.setSampleBufferDelegate(self, queue: avVideoOutputQueue)

                captureSession.addOutput(videoDataOutput)

                videoFileOutput = AVCaptureMovieFileOutput()
            }
        }
    }

    private func startAudioLevelsPollingTimer() {
        audioLevelsPollingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(KTCameraView.pollForAudioLevels), userInfo: nil, repeats: true)
        audioLevelsPollingTimer.fire()
    }

    private func stopAudioLevelsPollingTimer() {
        if let timer = audioLevelsPollingTimer {
            timer.invalidate()
            audioLevelsPollingTimer = nil
        }
    }

    func setCapturePreviewOrientationWithDeviceOrientation(deviceOrientation: UIDeviceOrientation, size: CGSize) {
        if  let capturePreviewLayer = capturePreviewLayer {
            capturePreviewLayer.frame.size = size

            if let connection = capturePreviewLayer.connection {
                switch (deviceOrientation) {
                case .Portrait:
                    connection.videoOrientation = .Portrait
                case .LandscapeRight:
                    connection.videoOrientation = .LandscapeLeft
                case .LandscapeLeft:
                    connection.videoOrientation = .LandscapeRight
                default:
                    connection.videoOrientation = .Portrait
                }
            }
        }
    }

    func pollForAudioLevels() {
        if audioDataOutput == nil {
            return
        }

        if audioDataOutput.connections.count > 0 {
            let connection = audioDataOutput.connections[0] as! AVCaptureConnection
            let channels = connection.audioChannels

            for channel in channels {
                let avg = channel.averagePowerLevel
                let peak = channel.peakHoldLevel

                delegate?.cameraView(self, didMeasureAveragePower: avg, peakHold: peak, forAudioChannel: channel as! AVCaptureAudioChannel)
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

    func startCapture(device: AVCaptureDevice) {
        if captureSession != nil {
            stopCapture()
        }

        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .NotDetermined {
            NSNotificationCenter.defaultCenter().postNotificationName("ApplicationWillRequestMediaAuthorization")
        }

        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.ContinuousAutoFocus) {
                device.focusMode = .ContinuousAutoFocus
            } else if device.isFocusModeSupported(.AutoFocus) {
                device.focusMode = .AutoFocus
            }

            device.unlockForConfiguration()
        } catch let error as NSError {
            logWarn(error.localizedDescription)
            delegate?.cameraViewCaptureSessionFailedToInitializeWithError(error)
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            captureSession.addInput(input)

            capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            capturePreviewLayer.frame = bounds
            capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
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

        if let _ = capturePreviewLayer {
            capturePreviewLayer.removeFromSuperlayer()
            capturePreviewLayer = nil
        }
    }

    func capture() {
        if let mode = delegate?.outputModeForCameraView(self) {
            switch mode {
            case .Audio:
                if recording == false {
                    // captureAudio()
                } else {
                    // audioFileOutput.stopRecording()
                }
                break
            case .Photo:
                captureFrame()
                break
            case .Selfie:
                captureFrame()
                break
            case .Video:
                if recording == false {
                    captureVideo()
                } else {
                    videoFileOutput.stopRecording()
                }
                break
            case .VideoSampleBuffer:
                if recording == false {
                    captureVideo()
                } else {
                    captureSession.removeOutput(videoDataOutput)
                }
                break
            }
        }
    }

    private func captureFrame() {
        delegate?.cameraViewBeganAsyncStillImageCapture(self)

        if isSimulator() {
            if let window = UIApplication.sharedApplication().keyWindow {
                UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.mainScreen().scale)
                window.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                delegate?.cameraView(self, didCaptureStillImage: image)
            }
            return
        }

        dispatch_async(avCameraOutputQueue) {
            if let cameraOutput = self.stillCameraOutput {
                if let connection = cameraOutput.connectionWithMediaType(AVMediaTypeVideo) {
                    if let videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue) {
                        connection.videoOrientation = videoOrientation
                    }

                    cameraOutput.captureStillImageAsynchronouslyFromConnection(connection) { imageDataSampleBuffer, error in
                        if error == nil {
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)

                            if let image = UIImage(data: imageData) {
                                self.delegate?.cameraView(self, didCaptureStillImage: image)
                            }
                        } else {
                            logWarn("Error capturing still image \(error)")
                        }
                    }
                }
            }
        }
    }

    private func captureVideo() {
        if isSimulator() {
            return
        }

        if let mode = delegate?.outputModeForCameraView(self) {
            switch mode {
            case .Video:
                if captureSession.canAddOutput(videoFileOutput) {
                    captureSession.addOutput(videoFileOutput)
                }

                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let outputFileURL = NSURL(fileURLWithPath: "\(paths.first!)/\(NSDate().timeIntervalSince1970).m4v")
                videoFileOutput.startRecordingToOutputFileURL(outputFileURL, recordingDelegate: self)
                break
            case .VideoSampleBuffer:
                if captureSession.canAddOutput(videoDataOutput) {
                    captureSession.addOutput(videoDataOutput)
                }
                break
            default:
                break
            }
        }
    }

    // MARK: AVCaptureFileOutputRecordingDelegate

    public func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        recording = true

        delegate?.cameraView(self, didStartVideoCaptureAtURL: fileURL)
    }

    public func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        recording = false

        delegate?.cameraView(self, didFinishVideoCaptureAtURL: outputFileURL)
        captureSession.removeOutput(videoFileOutput)
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate

    public func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        //println("dropped samples \(sampleBuffer)")
    }

    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
//        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
//        CVPixelBufferLockBaseAddress(imageBuffer, 0)
//
//        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
//        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
//        let width = CVPixelBufferGetWidth(imageBuffer)
//        let height = CVPixelBufferGetHeight(imageBuffer)
//
//        let colorSpace = CGColorSpaceCreateDeviceRGB()!
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue).rawValue
//        let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
//
//        let quartzImage = CGBitmapContextCreateImage(context)!
//        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
//
//        let frame = UIImage(CGImage: quartzImage)
    }

    // MARK: AVCaptureMetadataOutputObjectsDelegate

    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for object in metadataObjects {
            if let metadataFaceObject = object as? AVMetadataFaceObject {
                let detectedFace = capturePreviewLayer.transformedMetadataObjectForMetadataObject(metadataFaceObject)
                delegate?.cameraView(self, didOutputMetadataFaceObject: detectedFace as! AVMetadataFaceObject)
            }
        }

        if renderFacialRecognition {
            dispatch_after_delay(0.0) {
                self.clearDetectedMetadataObjects()
                self.showDetectedMetadataObjects(metadataObjects)
            }
        }
    }


    private func clearDetectedMetadataObjects() {
        if let codeDetectionLayer = codeDetectionLayer {
            codeDetectionLayer.sublayers = nil
        }
    }

    private func showDetectedMetadataObjects(metadataObjects: [AnyObject]!) {
        for object in metadataObjects {
            if let metadataFaceObject = object as? AVMetadataFaceObject {
                if let detectedCode = capturePreviewLayer.transformedMetadataObjectForMetadataObject(metadataFaceObject) as? AVMetadataFaceObject {
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.strokeColor = UIColor.greenColor().CGColor
                    shapeLayer.fillColor = UIColor.clearColor().CGColor
                    shapeLayer.lineWidth = 1.0
                    shapeLayer.lineJoin = kCALineJoinRound
                    shapeLayer.path = UIBezierPath(rect: detectedCode.bounds).CGPath
                    codeDetectionLayer.addSublayer(shapeLayer)
                }
            }
        }
    }
}