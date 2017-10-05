//
//  UIViewControllerExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit
import MBProgressHUD

public extension UIViewController {

    // MARK: Child view controller presentation

    func presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool) {
        present(viewControllerToPresent, animated: animated, completion: nil)
    }

    // MARK: MBProgressHUD

    func showHUD() {
        DispatchQueue.main.async {
            self.showHUD(inView: self.view)
        }
    }

    func showHUD(inView view: UIView) {
        var hud: MBProgressHUD! = MBProgressHUD(for: view)

        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        } else {
            hud.show(animated: true)
        }
    }

    func showHUDWithText(_ text: String) {
        var hud: MBProgressHUD! = MBProgressHUD(for: view)

        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        } else {
            hud.show(animated: true)
        }

        hud.label.text = text
    }

    func hideHUD() {
        DispatchQueue.main.async {
            self.hideHUD(inView: self.view)
        }
    }

    func hideHUD(inView view: UIView!) {
        if let hud = MBProgressHUD(for: view) {
            hud.hide(animated: true)
        }
    }

    func hideHUDWithText(_ text: String, completion: VoidBlock? = nil) {
        if let hud = MBProgressHUD(for: view) {
            hud.mode = .text
            hud.label.text = text

            if let completionBlock = completion {
                dispatch_after_delay(1.5) {
                    hud.hide(animated: true)
                    completionBlock()
                }
            } else {
                hud.hide(animated: true, afterDelay: 1.5)
            }
        }
    }

    // MARK: UIAlertController

    func showToast(_ title: String, dismissAfter delay: TimeInterval = 1.5) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        presentViewController(alertController, animated: true)

        dispatch_after_delay(delay) {
            self.dismiss(animated: true)
        }
    }
}
