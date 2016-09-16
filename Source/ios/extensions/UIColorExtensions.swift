//
//  UIColorExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UIColor {

    convenience init(_ hexString: String) {
        var rgb: UInt32 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 1
        scanner.scanHexInt32(&rgb)

        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }

    class func resizedColorWithPatternImage(_ patternImage: UIImage!, rect: CGRect) -> UIColor! {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        patternImage.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: resizedImage!)
    }
}
