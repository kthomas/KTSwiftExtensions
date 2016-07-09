//
//  KTModel.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 7/9/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import ObjectMapper

public class KTModel: NSObject, Mappable {

    internal var ivars: [String] {
        var count: UInt32 = 0
        let ivars: UnsafeMutablePointer<Ivar> = class_copyIvarList(self.dynamicType, &count)

        var ivarStrings = [String]()
        for i in 0..<count {
            let key = NSString(CString: ivar_getName(ivars[Int(i)]), encoding: NSUTF8StringEncoding) as! String
            ivarStrings.append(key)
        }
        ivars.dealloc(Int(count))
        return ivarStrings
    }

    public override var description: String {
        return "\(toJSONString(true))"
    }

    public override required init() {
        super.init()
    }

    public required init?(_ map: Map){

    }

    public func mapping(map: Map) {
        // no-op by default
    }
}
