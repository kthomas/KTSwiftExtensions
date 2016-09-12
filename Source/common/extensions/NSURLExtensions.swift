//
//  NSURLExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension NSURL {

    convenience init!(_ urlString: String) {
        self.init(string: urlString)
    }
}
