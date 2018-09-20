//
//  UIViewExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UIView {

    var width: CGFloat {
        return bounds.width
    }

    var height: CGFloat {
        return bounds.height
    }

    func addBorder(_ width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    func addDropShadow() {
        return addDropShadow(width: 1, height: 2, radius: 2, opacity: 0.75)
    }

    func addDropShadow(width: CGFloat = 1, height: CGFloat = 1, radius: CGFloat, opacity: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: width, height: height)
    }

    func addGradient(_ startColor: UIColor, endColor: UIColor, horizontal: Bool = false) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]

        if horizontal {
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        layer.insertSublayer(gradient, at: 0)
    }

    func disableTapToDismissKeyboard() {
        if let gestureRecognizers = gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                (gestureRecognizer as UIGestureRecognizer).removeTarget(self, action: #selector(endEditing))
            }
        }
    }

    func enableTapToDismissKeyboard() {
        disableTapToDismissKeyboard()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
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

    func roundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }

    func toImage() -> UIImage {
        var image: UIImage!
        var viewBounds = bounds
        if viewBounds.size == .zero {
            if layer.isKind(of: CAShapeLayer.self) {
                if let path = (layer as! CAShapeLayer).path {
                    viewBounds = path.boundingBoxOfPath
                }
            } else {
                if let sublayers = layer.sublayers {
                    for sublayer in sublayers {
                        if sublayer.isKind(of: CAShapeLayer.self) {
                            if let path = (sublayer as! CAShapeLayer).path {
                                viewBounds = path.boundingBoxOfPath
                                break
                            }
                        }
                    }
                }
            }
        }

        UIGraphicsBeginImageContextWithOptions(viewBounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }

    class func transitionWithView(_ view: UIView, duration: TimeInterval = 0.3, options: UIView.AnimationOptions = .transitionCrossDissolve, animations: @escaping VoidBlock) {
        transition(with: view, duration: duration, options: options, animations: animations)
    }
}
