//
//  KTApiService.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/9/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public typealias KTApiSuccessHandler = (AnyObject?) -> Void
public typealias KTApiFailureHandler = (NSHTTPURLResponse?, AnyObject?, NSError?) -> Void

public class KTApiService: NSObject {

    private static let instance = KTApiService()

    private var dispatchQueue: dispatch_queue_t!

    public class func sharedService() -> KTApiService {
        return instance
    }

    public required override init() {
        super.init()

        dispatchQueue = dispatch_queue_create("api.dispatchQueue", DISPATCH_QUEUE_CONCURRENT)
    }

    public func objectClassForPath(path: String) -> AnyClass? {
        var path = path
        let parts = path.characters.split("/").map { String($0) }
        if parts.count > 5 {
            path = [parts[3], parts[5]].joinWithSeparator("/")
            path = path.componentsSeparatedByString("/").last!
        } else if parts.count > 3 {
            path = [parts[1], parts[3]].joinWithSeparator("/")
            path = path.componentsSeparatedByString("/").last!
        } else {
            path = parts[1]
        }
        if path =~ "^(.*)s$" {
            path = path.substringToIndex(path.endIndex.predecessor())
        }

        let targetName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] ?? ""
        return NSClassFromString("\(targetName!).\(path.capitalizedString)")
    }

    public func execute(request: Request, successHandler: KTApiSuccessHandler?, failureHandler: KTApiFailureHandler?) {
        request.responseJSON(queue: dispatchQueue) { response in
            let error = response.result.error

            if error == nil {
                let statusCode = response.response!.statusCode
                log("Network request successful [status: \(statusCode); request duration: \(response.timeline.requestDuration * 1000.0)ms; total duration: \(response.timeline.totalDuration * 1000.0)]:\n\(request)")

                if let value = response.result.value {
                    if let clazz = self.objectClassForPath(request.request?.URL?.path ?? "") as? KTModel.Type {
                        var obj: AnyObject?

                        if statusCode < 300 {
                            if let val = value as? [String : AnyObject] {
                                let map = Map(mappingType: .FromJSON,
                                              JSONDictionary: val,
                                              toObject: true,
                                              context: nil)
                                obj = clazz.init()
                                (obj as! KTModel).mapping(map)
                            } else if let val = value as? [[String : AnyObject]] {
                                var objects = [KTModel]()
                                for v in val {
                                    let map = Map(mappingType: .FromJSON,
                                                  JSONDictionary: v,
                                                  toObject: true,
                                                  context: nil)
                                    let objInstance = clazz.init()
                                    objInstance.mapping(map)
                                    objects.append(objInstance)
                                }
                                obj = objects
                            }

                            if let obj = obj {
                                log("Parsed response value:\n\(obj)")
                            }

                            dispatch_async_main_queue {
                                successHandler?(obj)
                            }
                        } else {
                            log("Parsed response with \(statusCode) status code")

                            switch statusCode {
                            case 401:
                                NSNotificationCenter.defaultCenter().postNotificationName("ApplicationUserShouldLogout")

                            default:
                                break
                            }

                            if let val = value as? [String : AnyObject] {
                                let map = Map(mappingType: .FromJSON,
                                              JSONDictionary: val,
                                              toObject: true,
                                              context: nil)
                                obj = KTError()
                                (obj as! KTModel).mapping(map)
                                
                                log("\(statusCode) response included error payload:\n\((obj as! KTModel).toJSON())")
                            }
                            
                            dispatch_async_main_queue {
                                failureHandler?(response.response, obj, nil)
                            }
                        }
                    } else {
                        request.responseData { dataResponse in
                            if statusCode < 300 {
                                dispatch_async_main_queue {
                                    successHandler?(dataResponse.result.value)
                                }
                            } else {
                                log("Parsed data response with \(statusCode) status code")
                                dispatch_async_main_queue {
                                    failureHandler?(dataResponse.response, nil, nil)
                                }
                            }
                        }
                    }
                }
            } else {
                if error!.code == -6006 {
                    request.responseData { dataResponse in
                        let statusCode = dataResponse.response!.statusCode

                        if statusCode < 300 {
                            dispatch_async_main_queue {
                                successHandler?(dataResponse.result.value)
                            }
                        } else {
                            log("Parsed data response with \(statusCode) status code")
                            dispatch_async_main_queue {
                                failureHandler?(dataResponse.response, nil, nil)
                            }
                        }
                    }
                } else {
                    log("Error with network request:\n\(request); \(error); retrying...")
                    KTApiService.sharedService().execute(Alamofire.request(request.request!.URLRequest),
                                                         successHandler: successHandler,
                                                         failureHandler: failureHandler)
                }
            }
        }
    }
}
