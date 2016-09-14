//
//  UIViewExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UIView {

    func addBorder(width: CGFloat, color: UIColor) {
        layer.borderColor = color.CGColor
        layer.borderWidth = width
    }

    func addDropShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.75
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSizeMake(1.0, 2.0)
    }

    func addDropShadow(size: CGSize, radius: CGFloat, opacity: CGFloat) {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = radius
        layer.shadowOffset = size
    }

    func addGradient(startColor: UIColor, endColor: UIColor, horizontal: Bool = false) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [startColor.CGColor, endColor.CGColor]

        if horizontal {
            gradient.startPoint = CGPointMake(0.0, 0.5)
            gradient.endPoint = CGPointMake(1.0, 0.5)
        }

        layer.insertSublayer(gradient, atIndex: 0)
    }

    func disableTapToDismissKeyboard() {
        if let gestureRecognizers = gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                (gestureRecognizer as UIGestureRecognizer).removeTarget(self, action: #selector(UIView.endEditing(_:)))
            }
        }
    }

    func enableTapToDismissKeyboard() {
        disableTapToDismissKeyboard()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:))))
    }

    func makeCircular() {
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }

    func removeGestureRecognizers() {
        if let gestureRecognizers = gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                removeGestureRecognizer(gestureRecognizer)
            }
        }
    }

    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
    }

    func toImage() -> UIImage! {
        var image: UIImage!
        var viewBounds = bounds
        if viewBounds.size == CGSizeZero {
            if layer.isKindOfClass(CAShapeLayer) {
                if let path = (layer as! CAShapeLayer).path {
                    viewBounds = CGPathGetPathBoundingBox(path)
                }
            } else {
                if let sublayers = layer.sublayers {
                    for sublayer in sublayers {
                        if sublayer.isKindOfClass(CAShapeLayer) {
                            if let path = (sublayer as! CAShapeLayer).path {
                                viewBounds = CGPathGetPathBoundingBox(path)
                                break
                            }
                        }
                    }
                }
            }
        }

        UIGraphicsBeginImageContextWithOptions(viewBounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            layer.renderInContext(context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }

    class func transitionWithView(view: UIView, duration: NSTimeInterval = 0.3, options: UIViewAnimationOptions = .TransitionCrossDissolve, animations: VoidBlock) {
        transitionWithView(view, duration: duration, options: options, animations: animations, completion: nil)
    }
}
