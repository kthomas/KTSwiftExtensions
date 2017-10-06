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
public typealias KTApiFailureHandler = (HTTPURLResponse?, AnyObject?, NSError?) -> Void

public class KTApiService: NSObject {
    public static let shared = KTApiService()

    fileprivate var dispatchQueue: DispatchQueue!

    public required override init() {
        super.init()

        dispatchQueue = DispatchQueue(label: "api.dispatchQueue", attributes: DispatchQueue.Attributes.concurrent)
    }

    public func objectClassForPath(_ path: String) -> AnyClass? {
        var path = path
        let parts = path.characters.split(separator: "/").map { String($0) }
        if parts.count > 5 {
            path = [parts[3], parts[5]].joined(separator: "/")
            path = path.components(separatedBy: "/").last!
        } else if parts.count > 3 {
            path = [parts[1], parts[3]].joined(separator: "/")
            path = path.components(separatedBy: "/").last!
        } else {
            path = parts[1]
        }
        if path =~ "^(.*)s$" {
            path = path.substring(to: path.characters.index(before: path.endIndex))
        }

        let targetName = Bundle.main.infoDictionary?["CFBundleName"] ?? ""
        return NSClassFromString("\(targetName).\(path.capitalized)")
    }

    public func execute(_ request: DataRequest, successHandler: KTApiSuccessHandler?, failureHandler: KTApiFailureHandler?) {
        request.responseJSON(queue: dispatchQueue) { response in
            let error = response.result.error

            if error == nil {
                let statusCode = response.response!.statusCode
                let requestDurationMillis = response.timeline.requestDuration * 1000.0
                logInfo("Network request successful [status: \(statusCode); request duration: \(requestDurationMillis)ms; total duration: \(requestDurationMillis)]:\n\(request)")

                if let value = response.result.value {
                    if statusCode == 204 {
                        dispatch_async_main_queue {
                            successHandler?(nil)
                        }
                        return
                    }

                    if let clazz = self.objectClassForPath(request.request?.url?.path ?? "") as? KTModel.Type {
                        var obj: AnyObject?

                        if statusCode < 300 {
                            if let val = value as? [String: AnyObject] {
                                let map = Map(mappingType: .fromJSON,
                                              JSON: val,
                                              toObject: true,
                                              context: nil)
                                obj = clazz.init()
                                (obj as! KTModel).mapping(map: map)
                            } else if let val = value as? [[String: AnyObject]] {
                                var objects = [KTModel]()
                                for v in val {
                                    let map = Map(mappingType: .fromJSON,
                                                  JSON: v,
                                                  toObject: true,
                                                  context: nil)
                                    let objInstance = clazz.init()
                                    objInstance.mapping(map: map)
                                    objects.append(objInstance)
                                }
                                obj = objects as AnyObject
                            }

                            dispatch_async_main_queue {
                                successHandler?(obj)
                            }
                        } else {
                            logWarn("Parsed response with \(statusCode) status code")

                            switch statusCode {
                            case 401:
                                NotificationCenter.default.postNotificationName("ApplicationUserShouldLogout")

                            default:
                                break
                            }

                            if let val = value as? [String: AnyObject] {
                                let map = Map(mappingType: .fromJSON,
                                              JSON: val,
                                              toObject: true,
                                              context: nil)
                                obj = KTError()
                                (obj as! KTModel).mapping(map: map)

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
                                    successHandler?(dataResponse.result.value as AnyObject?)
                                }
                            } else {
                                logWarn("Parsed data response with \(statusCode) status code")
                                dispatch_async_main_queue {
                                    failureHandler?(dataResponse.response, nil, nil)
                                }
                            }
                        }
                    }
                }
            } else if let error = error as? NSError {
                if error.code == -6006 {
                    request.responseData { dataResponse in
                        let statusCode = dataResponse.response!.statusCode

                        if statusCode < 300 {
                            dispatch_async_main_queue {
                                successHandler?(dataResponse.result.value as AnyObject?)
                            }
                        } else {
                            logWarn("Parsed data response with \(statusCode) status code")
                            dispatch_async_main_queue {
                                failureHandler?(dataResponse.response, nil, nil)
                            }
                        }
                    }
                } else {
                    logWarn("Error with network request:\n\(request); \(error); retrying...")
                    self.execute(Alamofire.request(request.request!),
                                 successHandler: successHandler,
                                 failureHandler: failureHandler)
                }
            }
        }
    }
}
