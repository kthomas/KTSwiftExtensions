//
//  KTError.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/9/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import ObjectMapper

class KTError: KTModel {

    public var message: String!
    public var status: Int!

    public required init?(_ map: Map){
        super.init(map)
    }

    public override required init() {
        super.init()
    }

    public override func mapping(map: Map) {
        message <- map["message"]
        status <- map["status"]
    }
}
