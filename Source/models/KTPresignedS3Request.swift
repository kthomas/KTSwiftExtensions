//
//  KTPresignedS3Request.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/4/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import ObjectMapper

public class KTPresignedS3Request: Mappable {

    var metadata = [String : String]()
    var signedHeaders = [String : String]()
    var url: String!

    public required init?(_ map: Map){

    }

    public func mapping(map: Map) {
        metadata <- map["metadata"]
        signedHeaders <- map["signed_headers"]
        url <- map["url"]
    }
}
