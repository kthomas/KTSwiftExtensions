//
//  NSDateExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension NSDate {

    override public var debugDescription: String {
        return NSDateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss a").stringFromDate(self)
    }

    class func fromString(string: String!) -> NSDate! {
        let dateFormatter = NSDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZZ")
        return dateFormatter.dateFromString(string)
    }

    class func monthNameForNumber(month: Int) -> String {
        let dateFormatter = NSDateFormatter()
        return (dateFormatter.monthSymbols as NSArray).objectAtIndex(month - 1) as! String
    }

    func format(dateFormat: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(self)
    }

    var timeString: String? {
        let dateFormatter = NSDateFormatter(dateFormat: "hh:mm a")
        return dateFormatter.stringFromDate(self)
    }

    var hour: Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: self).hour
    }

    var minutes: Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: self).minute
    }

    var minutesString: String {
        var str = String(minutes)
        if minutes < 10 {
            str = "0\(str)"
        }
        return str
    }

    func secondsSince(date: NSDate) -> NSTimeInterval {
        let seconds = NSDate().timeIntervalSinceDate(date)
        return round(seconds * 100) / 100
    }

    var utcString: String {
        return format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }

    var monthName: String {
        let dateFormatter = NSDateFormatter(dateFormat: "MMMM")
        return dateFormatter.stringFromDate(self)
    }

    var atMidnight: NSDate {
        let components = NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day)
        let componentsWithoutTime = NSCalendar.currentCalendar().components(components, fromDate: self)
        return NSCalendar.currentCalendar().dateFromComponents(componentsWithoutTime)!
    }

    var month: Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: self).month
    }

    var dayOfMonth: Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: self).day
    }

    var year: Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: self).year
    }

    var dayOfWeek: String {
        let dateFormatter = NSDateFormatter(dateFormat: "EEEE")
        return dateFormatter.stringFromDate(self)
    }

    var yearString: String {
        let dateFormatter = NSDateFormatter(dateFormat: "yyyy")
        return dateFormatter.stringFromDate(self)
    }
}