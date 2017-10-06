//
//  UIImageExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UIImage {

    convenience init!(_ imageName: String) {
        self.init(named: imageName)
    }

    class func imageFromDataURL(_ dataURL: URL) -> UIImage? {
        if let data = try? Data(contentsOf: dataURL) {
            return UIImage(data: data)
        }
        return nil
    }

    func crop(_ rect: CGRect) -> UIImage? {
        if let image = cgImage?.cropping(to: rect) {
            return UIImage(cgImage: image)
        }
        return nil
    }

    func resize(_ rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func scaledToWidth(_ width: CGFloat) -> UIImage? {
        let originalWidth = self.size.width
        let scale = width / originalWidth
        let height = self.size.height * scale
        let width = originalWidth * scale

        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let size = rect.size

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
