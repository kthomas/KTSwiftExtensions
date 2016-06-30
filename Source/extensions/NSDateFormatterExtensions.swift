//
//  NSDateFormatterExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import Foundation

extension NSDateFormatter {

    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }

    convenience init(dateStyle: NSDateFormatterStyle) {
        self.init()
        self.dateStyle = dateStyle
    }

    class func localizedStringFromDate(date: NSDate, dateStyle: NSDateFormatterStyle) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: dateStyle, timeStyle: .NoStyle)
    }
}
