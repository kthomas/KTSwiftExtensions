//
//  KTPresignedS3Request.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/4/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import ObjectMapper

open class KTPresignedS3Request: KTModel {

    open var fields: [String: String]!
    open var metadata = [String: String]()
    open var signedHeaders = [String: String]()
    open var url: String!

    open override func mapping(map: Map) {
        metadata <- map["metadata"]
        fields <- map["fields"]
        signedHeaders <- map["signed_headers"]
        url <- map["url"]
    }
}
