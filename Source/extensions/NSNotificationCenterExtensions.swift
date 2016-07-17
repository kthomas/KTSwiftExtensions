//
//  NSNotificationCenterExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension NSNotificationCenter {

    func postNotificationName(aName: String) {
        postNotificationName(aName, object: nil)
    }

    func addObserver(observer: AnyObject, selector: Selector, name: String?) {
        addObserver(observer, selector: selector, name: name, object: nil)
    }

    func addObserverForName(name: String?, queue: NSOperationQueue? = nil, usingBlock block: (NSNotification!) -> Void) {
        addObserverForName(name, object: nil, queue: queue, usingBlock: block)
    }
}
