//
//  ArrayExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension Array {

    func each(_ block: (Element) -> Void) {
        for object in self {
            block(object)
        }
    }

    func findFirst(_ conditionBlock: (Element) -> Bool) -> Element? {
        for object in self {
            if conditionBlock(object) {
                return object
            }
        }
        return nil
    }

    func indexOfObject<T: Equatable>(_ obj: T) -> Int? {
        var idx = 0
        for elem in self {
            if obj == elem as! T {
                return idx
            }
            idx += 1
        }
        return nil
    }

    func toJSON() -> String! {
        let jsonData = encodeJSON(self as AnyObject)
        return NSString(bytes: (jsonData as NSData).bytes, length: jsonData.count, encoding: String.Encoding.utf8.rawValue) as! String
    }

    mutating func removeObject<U: Equatable>(_ object: U) {
        for (index, objectToCompare) in enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    remove(at: index)
                    break
                }
            }
        }
    }
}
