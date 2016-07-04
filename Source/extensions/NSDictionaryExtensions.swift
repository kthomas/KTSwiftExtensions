//
//  NSDictionaryExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import Foundation

extension NSDictionary {

    func toJSON() -> String! {
        let jsonData = encodeJSON(self)
        return NSString(bytes: jsonData.bytes, length: jsonData.length, encoding: NSUTF8StringEncoding) as! String
    }

    func toQueryString() -> String {
        var queryString = ""
        for (key, value) in self {
            let encodedName = (key as! String).urlEncodedString()
            let encodedValue = "\(value)".urlEncodedString()
            let encodedParameter = "\(encodedName)=\(encodedValue)"
            queryString = queryString + (queryString == "" ? "" : "&") + encodedParameter
        }
        return queryString
    }
}