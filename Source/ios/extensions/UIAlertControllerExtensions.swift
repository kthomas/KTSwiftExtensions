//
//  UIAlertControllerExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 11/7/17.
//  Copyright © 2017 Kyle Thomas. All rights reserved.
//

import UIKit

extension UIAlertController {

    public func show() {
        show(animated: true)
    }

    public func show(animated: Bool) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.tintColor = UIApplication.shared.keyWindow!.tintColor
        alertWindow.windowLevel = UIApplication.shared.windows.last!.windowLevel + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController!.present(self, animated: animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let window = UIApplication.shared.keyWindow!
        if window.windowLevel > 0.0, let vc = window.rootViewController?.presentedViewController, vc == self {
            let alertWindow = UIApplication.shared.keyWindow!
            alertWindow.rootViewController = nil
            alertWindow.isHidden = true
            alertWindow.resignFirstResponder()
            alertWindow.removeFromSuperview()
        }
    }
}
