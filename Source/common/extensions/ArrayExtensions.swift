//
//  ArrayExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension Array {
    func toJSON() -> String {
        let jsonData = encodeJSON(self)
        return NSString(bytes: (jsonData as NSData).bytes, length: jsonData.count, encoding: String.Encoding.utf8.rawValue)! as String
    }

    mutating func removeObject<U: Equatable>(_ object: U) {
        for (index, objectToCompare) in enumerated() {
            if let to = objectToCompare as? U, object == to {
                remove(at: index)
                break
            }
        }
    }
}
