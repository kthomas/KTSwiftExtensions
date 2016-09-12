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
                             successHandler: KTApiSuccessHandler?,
                             failureHandler: KTApiFailureHandler?) {
        let request = Alamofire.request(.GET, url, parameters: ["filename": filename, "metadata": metadata.toJSONString()], headers: headers)
        KTApiService.sharedService().execute(request, successHandler: successHandler, failureHandler: failureHandler)
    }

    public class func upload(presignedS3Request: KTPresignedS3Request,
                      data: NSData,
                      withMimeType mimeType: String,
                      successHandler: KTApiSuccessHandler?,
                      failureHandler: KTApiFailureHandler?) {
        if presignedS3Request.fields != nil {
            Alamofire.upload(.POST, NSURL(presignedS3Request.url).absoluteString, headers: presignedS3Request.signedHeaders,
                multipartFormData: { multipartFormData in
                    for (name, value) in presignedS3Request.fields {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: name)
                    }
                    multipartFormData.appendBodyPart(data: data, name: "file", fileName: "filename", mimeType: mimeType)
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let request, _, _):
                        KTApiService.sharedService().execute(request, successHandler: successHandler, failureHandler: failureHandler)
                    case .Failure(let encodingError):
                        logWarn("Multipart upload not attempted due to encoding error; \(encodingError)")
                    }
                }
            )
        } else {
            let request = Alamofire.upload(.PUT, NSURL(presignedS3Request.url), headers: presignedS3Request.signedHeaders, data: data)
            KTApiService.sharedService().execute(request, successHandler: successHandler, failureHandler: failureHandler)
        }
    }
}
