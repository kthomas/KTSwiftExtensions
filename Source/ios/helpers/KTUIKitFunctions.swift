//
//  KTUIKitFunctions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public func isIPad() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .pad
}

public func isIPhone() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .phone
}

public func isIPhone6Plus() -> Bool {
    if !isIPhone() {
        return false
    }
    return UIScreen.main.scale > 2.9
}

public func windowBounds() -> CGRect {
    return UIApplication.shared.keyWindow!.bounds
}
