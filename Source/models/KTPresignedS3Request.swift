//
//  KTPresignedS3Request.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/4/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import ObjectMapper

public class KTPresignedS3Request: KTModel {

    var metadata = [String : String]()
    var signedHeaders = [String : String]()
    var url: String!

    public required init?(_ map: Map){
        super.init(map)
    }

    public override required init() {
        super.init()
    }

    public override func mapping(map: Map) {
        metadata <- map["metadata"]
        signedHeaders <- map["signed_headers"]
        url <- map["url"]
    }
}
