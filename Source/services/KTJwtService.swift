//
//  KTJwtService.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 8/7/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import JWTDecode

public class KTJwtService: NSObject {

    public class func decode(token: String) -> JWT? {
        do {
            let jwt = try JWTDecode.decode(token)
            return jwt
        } catch let error as NSError {
            logWarn("JWT decoding failed: \(error.localizedDescription)")
        }

        return nil
    }
}
