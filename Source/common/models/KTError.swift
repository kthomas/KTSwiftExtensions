//
//  KTError.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/9/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import ObjectMapper

open class KTError: KTModel {

    open var message: String!
    open var status: Int!

    open override func mapping(map: Map) {
        message <- map["message"]
        status <- map["status"]
    }
}
