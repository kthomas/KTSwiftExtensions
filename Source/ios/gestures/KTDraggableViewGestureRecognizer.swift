//
//  KTDraggableViewGestureRecognizer.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/17/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

@objc
public protocol KTDraggableViewGestureRecognizerDelegate {
    @objc optional func draggableViewGestureRecognizer(_ gestureRecognizer: KTDraggableViewGestureRecognizer, shouldResetView view: UIView) -> Bool
    @objc optional func draggableViewGestureRecognizer(_ gestureRecognizer: KTDraggableViewGestureRecognizer, shouldAnimateResetView view: UIView) -> Bool
}

open class KTDraggableViewGestureRecognizer: UIGestureRecognizer {

    open var draggableViewGestureRecognizerDelegate: KTDraggableViewGestureRecognizerDelegate!

    open var initialView: UIView!
    public var initialFrame: CGRect!
    internal var initialSuperview: UIView!
    internal var initialAlpha: CGFloat!
    internal var touchesBeganTimestamp: Date!

    fileprivate var superviewChanged: Bool {
        if let initialView = initialView {
            if let initialSuperview = initialSuperview {
                return initialView.superview != initialSuperview
            }
        }
        return false
    }

    fileprivate var gestureInProgress: Bool {
        return touchesBeganTimestamp != nil
    }

    fileprivate func cleanup() {
        initialView = nil
        initialSuperview = nil
        initialFrame = nil
        initialAlpha = nil
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let view = touches.first!.view!
        if let superview = view.superview {
            initialSuperview = superview
            if superview.isKind(of: UICollectionViewCell.self) {
                while !initialSuperview.isKind(of: UICollectionView.self) {
                    initialSuperview = initialSuperview.superview!
                }
                initialView = superview
            } else if superview.superview!.isKind(of: UICollectionViewCell.self) {
                while !initialSuperview.isKind(of: UICollectionView.self) {
                    initialSuperview = initialSuperview.superview!
                }
                initialView = superview.superview!
            } else {
                initialView = view
            }
        } else {
            initialView = view
        }
        initialFrame = initialView.frame
        initialAlpha = initialView.alpha

        super.touchesBegan(touches, with: event)

        state = .began

        touchesBeganTimestamp = Date()
        applyTouches(touches)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        state = .ended

        applyTouches(touches)
        touchesBeganTimestamp = nil

        if let shouldResetView = draggableViewGestureRecognizerDelegate?.draggableViewGestureRecognizer?(self, shouldResetView: initialView) {
            if shouldResetView {
                var duration = 0.15
                var delay = 0.1
                if let shouldAnimate = draggableViewGestureRecognizerDelegate?.draggableViewGestureRecognizer?(self, shouldAnimateResetView: initialView) {
                    if !shouldAnimate {
                        duration = 0.0
                        delay = 0.0
                    }
                }
                UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut,
                    animations: {
                        self.initialView.frame = self.initialFrame
                        self.initialView.alpha = self.initialAlpha
                    },
                    completion: { _ in
                        if self.superviewChanged {
                            let window = UIApplication.shared.keyWindow!
                            self.initialView.removeFromSuperview()

                            self.initialView.frame = window.convert(self.initialView.frame, to: self.initialSuperview)
                            self.initialView.alpha = self.initialAlpha
                            self.initialSuperview.addSubview(self.initialView)
                            self.initialSuperview.bringSubview(toFront: self.initialView)
                        }

                        self.cleanup()
                    }
                )
            } else {
                cleanup()
            }
        } else {
            cleanup()
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        state = .cancelled

        touchesBeganTimestamp = nil

        cleanup()
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        applyTouches(touches)
    }

    fileprivate func applyTouches(_ touches: Set<UITouch>) {
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        for touch in touches {
            xOffset += touch.location(in: nil).x - touch.previousLocation(in: nil).x
            yOffset += touch.location(in: nil).y - touch.previousLocation(in: nil).y

            drag(xOffset, yOffset: yOffset)
        }
    }

    open func drag(_ xOffset: CGFloat, yOffset: CGFloat) {
        if let view = view {
            drag(view, xOffset: xOffset, yOffset: yOffset)
        }
    }

    internal func drag(_ view: UIView, xOffset: CGFloat, yOffset: CGFloat) {
        var newFrame = CGRect(origin: view.frame.origin, size: view.frame.size)
        newFrame.origin.x += xOffset
        newFrame.origin.y += yOffset
        view.frame = newFrame
    }
}
