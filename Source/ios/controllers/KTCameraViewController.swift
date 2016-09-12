//
//  KTCameraViewController.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit
import AVFoundation

public protocol KTCameraViewControllerDelegate {
    func outputModeForCameraViewController(viewController: KTCameraViewController) -> CameraOutputMode
    func cameraViewControllerCanceled(viewController: KTCameraViewController)

    func cameraViewControllerDidBeginAsyncStillImageCapture(viewController: KTCameraViewController)
    func cameraViewController(viewController: KTCameraViewController, didCaptureStillImage image: UIImage)

    func cameraViewController(viewController: KTCameraViewController, didSelectImageFromCameraRoll image: UIImage)
    func cameraViewController(KTCameraViewController: KTCameraViewController, didStartVideoCaptureAtURL fileURL: NSURL)
    func cameraViewController(KTCameraViewController: KTCameraViewController, didFinishVideoCaptureAtURL fileURL: NSURL)

    func cameraViewControllerShouldOutputFaceMetadata(viewController: KTCameraViewController) -> Bool
    func cameraViewControllerShouldRenderFacialRecognition(viewController: KTCameraViewController) -> Bool
    func cameraViewControllerDidOutputFaceMetadata(viewController: KTCameraViewController, metadataFaceObject: AVMetadataFaceObject)
    func cameraViewController(viewController: KTCameraViewController, didRecognizeText text: String!)
}

public class KTCameraViewController: UIViewController, KTCameraViewDelegate {

    var delegate: KTCameraViewControllerDelegate!
    var mode: ActiveDeviceCapturePosition = .Back
    var outputMode: CameraOutputMode = .Photo

    @IBOutlet public weak var backCameraView: KTCameraView!
    @IBOutlet public weak var frontCameraView: KTCameraView!

    @IBOutlet public weak var button: UIButton!

    private var activeCameraView: KTCameraView! {
        switch mode {
        case .Back:
            return backCameraView
        case .Front:
            return frontCameraView
        }
    }

    var isRunning: Bool {
        if let backCameraView = backCameraView {
            if backCameraView.isRunning {
                return true
            }
        }

        if let frontCameraView = frontCameraView {
            if frontCameraView.isRunning {
                return true
            }
        }

        return false
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(KTCameraViewController.dismiss(_:)))
        view.addGestureRecognizer(swipeGestureRecognizer)

        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)

        setupCameraUI()
        setupBackCameraView()
    }

    func setupCameraUI() {
        if let button = button {
            view.bringSubviewToFront(button)

            button.addTarget(self, action: #selector(KTCameraViewController.capture), forControlEvents: .TouchUpInside)
            let events = UIControlEvents.TouchUpInside.union(.TouchUpOutside).union(.TouchCancel).union(.TouchDragExit)
            button.addTarget(self, action: #selector(KTCameraViewController.renderDefaultButtonAppearance), forControlEvents: events)
            button.addTarget(self, action: #selector(KTCameraViewController.renderTappedButtonAppearance), forControlEvents: .TouchDown)

            button.addBorder(5.0, color: UIColor.whiteColor())
            button.makeCircular()

            renderDefaultButtonAppearance()
        }
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        if !isRunning {
            setupBackCameraView()
        }

        button?.enabled = true

        dispatch_after_delay(0.0) {
            self.button?.frame.origin.y = self.view.frame.size.height - 8.0 - self.button.frame.height
        }
    }

    deinit {
        activeCameraView?.stopCapture()
    }

    func capture() {
        button?.enabled = false
        activeCameraView?.capture()
    }

    func setupBackCameraView() {
        mode = .Back

        if let backCameraView = backCameraView {
            backCameraView.frame = view.frame
            backCameraView.delegate = self
            backCameraView.startBackCameraCapture()

            backCameraView.setCapturePreviewOrientationWithDeviceOrientation(UIDevice.currentDevice().orientation, size: view.frame.size)

            view.bringSubviewToFront(backCameraView)
        }

        if let button = button {
            view.bringSubviewToFront(button)
        }
    }

    func setupFrontCameraView() {
        mode = .Front

        if let frontCameraView = frontCameraView {
            frontCameraView.frame = view.frame
            frontCameraView.delegate = self
            frontCameraView.startFrontCameraCapture()

            frontCameraView.setCapturePreviewOrientationWithDeviceOrientation(UIDevice.currentDevice().orientation, size: view.frame.size)

            view.bringSubviewToFront(frontCameraView)
        }

        if let button = button {
            view.bringSubviewToFront(button)
        }
    }

    func teardownBackCameraView() {
        backCameraView?.stopCapture()
    }

    func teardownFrontCameraView() {
        frontCameraView?.stopCapture()
    }

    func dismiss(sender: UIBarButtonItem) {
        delegate?.cameraViewControllerCanceled(self)
    }

    func renderDefaultButtonAppearance() {

    }

    func renderTappedButtonAppearance() {

    }

    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        dispatch_after_delay(0.0) {
            self.button?.frame.origin.y = self.view.frame.height - 8.0 - self.button.frame.height
            self.activeCameraView?.setCapturePreviewOrientationWithDeviceOrientation(UIDevice.currentDevice().orientation, size: size)
        }
    }

    // MARK: KTCameraViewDelegate

    public
    func outputModeForCameraView(cameraView: KTCameraView) -> CameraOutputMode {
        if let delegate = delegate {
            return delegate.outputModeForCameraViewController(self)
        }
        return outputMode
    }

    public func cameraViewCaptureSessionFailedToInitializeWithError(error: NSError) {
        delegate?.cameraViewControllerCanceled(self)
    }

    public func cameraViewBeganAsyncStillImageCapture(cameraView: KTCameraView) {
        delegate?.cameraViewControllerDidBeginAsyncStillImageCapture(self)
    }

    public func cameraView(cameraView: KTCameraView, didCaptureStillImage image: UIImage) {
        delegate?.cameraViewController(self, didCaptureStillImage: image)
    }

    public func cameraView(cameraView: KTCameraView, didStartVideoCaptureAtURL fileURL: NSURL) {
        delegate?.cameraViewController(self, didStartVideoCaptureAtURL: fileURL)
    }

    public func cameraView(cameraView: KTCameraView, didFinishVideoCaptureAtURL fileURL: NSURL) {
        delegate?.cameraViewController(self, didFinishVideoCaptureAtURL: fileURL)
    }

    public func cameraView(cameraView: KTCameraView, didMeasureAveragePower avgPower: Float, peakHold: Float, forAudioChannel channel: AVCaptureAudioChannel) {

    }

    public func cameraView(cameraView: KTCameraView, didOutputMetadataFaceObject metadataFaceObject: AVMetadataFaceObject) {
        delegate?.cameraViewControllerDidOutputFaceMetadata(self, metadataFaceObject: metadataFaceObject)
    }

    public func cameraViewShouldEstablishAudioSession(cameraView: KTCameraView) -> Bool {
        return false
    }

    public func cameraViewShouldEstablishVideoSession(cameraView: KTCameraView) -> Bool {
        return outputModeForCameraView(cameraView) == .VideoSampleBuffer
    }

    public func cameraViewShouldOutputFaceMetadata(cameraView: KTCameraView) -> Bool {
        if let outputFaceMetadata = delegate?.cameraViewControllerShouldOutputFaceMetadata(self) {
            return outputFaceMetadata
        }
        return false
    }

    public func cameraViewShouldRenderFacialRecognition(cameraView: KTCameraView) -> Bool {
        if let renderFacialRecognition = delegate?.cameraViewControllerShouldRenderFacialRecognition(self) {
            return renderFacialRecognition
        }
        return false
    }
}
