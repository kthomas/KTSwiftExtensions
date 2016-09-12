//
//  KTUIKitFunctions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public func isIPad() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .Pad
}

public func isIPhone() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .Phone
}

public func isIPhone6Plus() -> Bool {
    if !isIPhone() {
        return false
    }
    return UIScreen.mainScreen().scale > 2.9
}

public func windowBounds() -> CGRect {
    return UIApplication.sharedApplication().keyWindow!.bounds
}
