//
//  KTS3Service.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/4/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper

public class KTS3Service: NSObject {

    public class func presign(url: NSURL,
                             filename: String,
                             metadata: [String : String],
                             headers: [String : String],
                             completionHandler: Response<KTPresignedS3Request, NSError> -> Void) {
        let request = Alamofire.request(.GET, url, parameters: ["filename": filename, "metadata": metadata.toJSONString()], headers: headers)
        request.responseObject(completionHandler: completionHandler)
    }

    public class func upload(presignedS3Request: KTPresignedS3Request,
                      data: NSData,
                      withMimeType mimeType: String,
                      completionHandler: Response<NSData, NSError> -> Void) {
        let request = Alamofire.upload(.PUT, NSURL(presignedS3Request.url), headers: presignedS3Request.signedHeaders, data: data)
        request.responseData(completionHandler: completionHandler)
    }
}
