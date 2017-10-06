//
//  NSDictionaryExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension NSDictionary {

    func toJSON() -> String {
        let jsonData = encodeJSON(self)
        return NSString(bytes: (jsonData as NSData).bytes, length: jsonData.count, encoding: String.Encoding.utf8.rawValue) as! String
    }
}
