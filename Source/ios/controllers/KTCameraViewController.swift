//
//  KTCameraViewController.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit
import AVFoundation

public protocol KTCameraViewControllerDelegate: class {
    func outputModeForCameraViewController(_ viewController: KTCameraViewController) -> CameraOutputMode
    func cameraViewControllerCanceled(_ viewController: KTCameraViewController)

    func cameraViewControllerDidBeginAsyncStillImageCapture(_ viewController: KTCameraViewController)
    func cameraViewController(_ viewController: KTCameraViewController, didCaptureStillImage image: UIImage)

    func cameraViewController(_ viewController: KTCameraViewController, didSelectImageFromCameraRoll image: UIImage)
    func cameraViewController(_ KTCameraViewController: KTCameraViewController, didStartVideoCaptureAtURL fileURL: URL)
    func cameraViewController(_ KTCameraViewController: KTCameraViewController, didFinishVideoCaptureAtURL fileURL: URL)

    func cameraViewControllerShouldOutputFaceMetadata(_ viewController: KTCameraViewController) -> Bool
    func cameraViewControllerShouldRenderFacialRecognition(_ viewController: KTCameraViewController) -> Bool
    func cameraViewControllerDidOutputFaceMetadata(_ viewController: KTCameraViewController, metadataFaceObject: AVMetadataFaceObject)
    func cameraViewController(_ viewController: KTCameraViewController, didRecognizeText text: String!)
}

public class KTCameraViewController: UIViewController, KTCameraViewDelegate {

    weak var delegate: KTCameraViewControllerDelegate?
    var mode: ActiveDeviceCapturePosition = .back
    var outputMode: CameraOutputMode = .photo

    @IBOutlet public weak var backCameraView: KTCameraView!
    @IBOutlet public weak var frontCameraView: KTCameraView!

    @IBOutlet public weak var button: UIButton!

    fileprivate var activeCameraView: KTCameraView! {
        switch mode {
        case .back:
            return backCameraView
        case .front:
            return frontCameraView
        }
    }

    var isRunning: Bool {
        if let backCameraView = backCameraView, backCameraView.isRunning {
            return true
        }

        if let frontCameraView = frontCameraView, frontCameraView.isRunning {
            return true
        }

        return false
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(KTCameraViewController.dismiss(_:)))
        view.addGestureRecognizer(swipeGestureRecognizer)

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        setupCameraUI()
        setupBackCameraView()
    }

    func setupCameraUI() {
        guard let button = button else { return }

        view.bringSubview(toFront: button)

        button.addTarget(self, action: #selector(KTCameraViewController.capture), for: .touchUpInside)
        let events = UIControlEvents.touchUpInside.union(.touchUpOutside).union(.touchCancel).union(.touchDragExit)
        button.addTarget(self, action: #selector(KTCameraViewController.renderDefaultButtonAppearance), for: events)
        button.addTarget(self, action: #selector(KTCameraViewController.renderTappedButtonAppearance), for: .touchDown)

        button.addBorder(5.0, color: UIColor.white)
        button.makeCircular()

        renderDefaultButtonAppearance()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if !isRunning {
            setupBackCameraView()
        }

        button?.isEnabled = true

        DispatchQueue.main.async {
            self.button?.frame.origin.y = self.view.frame.size.height - 8.0 - self.button.frame.height
        }
    }

    deinit {
        activeCameraView?.stopCapture()
    }

    func capture() {
        button?.isEnabled = false
        activeCameraView?.capture()
    }

    func setupBackCameraView() {
        mode = .back

        if let backCameraView = backCameraView {
            backCameraView.frame = view.frame
            backCameraView.delegate = self
            backCameraView.startBackCameraCapture()

            backCameraView.setCapturePreviewOrientationWithDeviceOrientation(UIDevice.current.orientation, size: view.frame.size)

            view.bringSubview(toFront: backCameraView)
        }

        if let button = button {
            view.bringSubview(toFront: button)
        }
    }

    func setupFrontCameraView() {
        mode = .front

        if let frontCameraView = frontCameraView {
            frontCameraView.frame = view.frame
            frontCameraView.delegate = self
            frontCameraView.startFrontCameraCapture()

            frontCameraView.setCapturePreviewOrientationWithDeviceOrientation(UIDevice.current.orientation, size: view.frame.size)

            view.bringSubview(toFront: frontCameraView)
        }

        if let button = button {
            view.bringSubview(toFront: button)
        }
    }

    func teardownBackCameraView() {
        backCameraView?.stopCapture()
    }

    func teardownFrontCameraView() {
        frontCameraView?.stopCapture()
    }

    func dismiss(_ sender: UIBarButtonItem) {
        delegate?.cameraViewControllerCanceled(self)
    }

    func renderDefaultButtonAppearance() {

    }

    func renderTappedButtonAppearance() {

    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.async {
            self.button?.frame.origin.y = self.view.frame.height - 8.0 - self.button.frame.height
            self.activeCameraView?.setCapturePreviewOrientationWithDeviceOrientation(UIDevice.current.orientation, size: size)
        }
    }

    // MARK: KTCameraViewDelegate

    public func outputModeForCameraView(_ cameraView: KTCameraView) -> CameraOutputMode {
        return delegate?.outputModeForCameraViewController(self) ?? outputMode
    }

    public func cameraViewCaptureSessionFailedToInitializeWithError(_ error: NSError) {
        delegate?.cameraViewControllerCanceled(self)
    }

    public func cameraViewBeganAsyncStillImageCapture(_ cameraView: KTCameraView) {
        delegate?.cameraViewControllerDidBeginAsyncStillImageCapture(self)
    }

    public func cameraView(_ cameraView: KTCameraView, didCaptureStillImage image: UIImage) {
        delegate?.cameraViewController(self, didCaptureStillImage: image)
    }

    public func cameraView(_ cameraView: KTCameraView, didStartVideoCaptureAtURL fileURL: URL) {
        delegate?.cameraViewController(self, didStartVideoCaptureAtURL: fileURL)
    }

    public func cameraView(_ cameraView: KTCameraView, didFinishVideoCaptureAtURL fileURL: URL) {
        delegate?.cameraViewController(self, didFinishVideoCaptureAtURL: fileURL)
    }

    public func cameraView(_ cameraView: KTCameraView, didMeasureAveragePower avgPower: Float, peakHold: Float, forAudioChannel channel: AVCaptureAudioChannel) {

    }

    public func cameraView(_ cameraView: KTCameraView, didOutputMetadataFaceObject metadataFaceObject: AVMetadataFaceObject) {
        delegate?.cameraViewControllerDidOutputFaceMetadata(self, metadataFaceObject: metadataFaceObject)
    }

    public func cameraViewShouldEstablishAudioSession(_ cameraView: KTCameraView) -> Bool {
        return false
    }

    public func cameraViewShouldEstablishVideoSession(_ cameraView: KTCameraView) -> Bool {
        return outputModeForCameraView(cameraView) == .videoSampleBuffer
    }

    public func cameraViewShouldOutputFaceMetadata(_ cameraView: KTCameraView) -> Bool {
        return delegate?.cameraViewControllerShouldOutputFaceMetadata(self) ?? false
    }

    public func cameraViewShouldRenderFacialRecognition(_ cameraView: KTCameraView) -> Bool {
        return delegate?.cameraViewControllerShouldRenderFacialRecognition(self) ?? false
    }
}
