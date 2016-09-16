//
//  NotificationCenterExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension NotificationCenter {

    func postNotificationName(_ aName: String) {
        post(name: Notification.Name(rawValue: aName), object: nil)
    }

    func addObserver(_ observer: AnyObject, selector: Selector, name: String?) {
        addObserver(observer, selector: selector, name: name.map { NSNotification.Name(rawValue: $0) }, object: nil)
    }

    func addObserverForName(_ name: String?, queue: OperationQueue? = nil, usingBlock block: @escaping (Notification!) -> Void) {
        self.addObserver(forName: name.map { NSNotification.Name(rawValue: $0) }, object: nil, queue: queue, using: block)
    }
}
