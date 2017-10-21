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

// This is a dummy class just to namespace the convenience methods
public class KTNotificationCenter {
    public class func post(name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }

    public class func addObserver(forName name: NSNotification.Name?, object: Any? = nil, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: block)
    }

    public class func addObserver(observer: Any, selector: Selector, name: NSNotification.Name?, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}
