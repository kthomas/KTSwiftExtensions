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
        KTApiService.sharedService().execute(request,
            successHandler: { object in
                successHandler?(object)
            },
            failureHandler: { response, object, error in
                failureHandler?(response, object, error)
            }
        )
    }

    public class func upload(presignedS3Request: KTPresignedS3Request,
                      data: NSData,
                      withMimeType mimeType: String,
                      successHandler: KTApiSuccessHandler?,
                      failureHandler: KTApiFailureHandler?) {
        let request = Alamofire.upload(.PUT, NSURL(presignedS3Request.url), headers: presignedS3Request.signedHeaders, data: data)
        KTApiService.sharedService().execute(request,
            successHandler: { object in
                successHandler?(object)
            },
            failureHandler: { response, object, error in
                failureHandler?(response, object, error)
            }
        )
    }
}
