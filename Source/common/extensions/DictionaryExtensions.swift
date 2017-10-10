//
//  DictionaryExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension Dictionary {

    func toJSONString() -> String {
        let jsonData = encodeJSON(self)
        return NSString(bytes: (jsonData as NSData).bytes, length: jsonData.count, encoding: String.Encoding.utf8.rawValue)! as String
    }

    func toQueryString() -> String {
        var queryString = ""
        for (key, value) in self {
            let encodedName = (key as! String).urlEncodedString()
            let encodedValue = "\(value)".urlEncodedString()
            let encodedParameter = "\(encodedName)=\(encodedValue)"
            queryString += (queryString == "" ? "" : "&") + encodedParameter
        }
        return queryString
    }
}
