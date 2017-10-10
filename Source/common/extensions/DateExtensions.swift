//
//  DateExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public extension Date {

    static func fromString(_ string: String) -> Date? {
        let dateFormatter = DateFormatter("yyyy-MM-dd'T'HH:mm:ssZZ")
        return dateFormatter.date(from: string)
    }

    static func monthNameForNumber(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.monthSymbols[month - 1]
    }

    var debugDescription: String {
        return DateFormatter("yyyy-MM-dd HH:mm:ss a").string(from: self)
    }

    var timeString: String? {
        let dateFormatter = DateFormatter("hh:mm a")
        return dateFormatter.string(from: self)
    }

    var hour: Int {
        return (Calendar.current as NSCalendar).components(.hour, from: self).hour!
    }

    var minutes: Int {
        return (Calendar.current as NSCalendar).components(.minute, from: self).minute!
    }

    var minutesString: String {
        var str = String(minutes)
        if minutes < 10 {
            str = "0\(str)"
        }
        return str
    }

    var utcString: String {
        return format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }

    var monthName: String {
        let dateFormatter = DateFormatter("MMMM")
        return dateFormatter.string(from: self)
    }

    var atMidnight: Date {
        let components = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day)
        let componentsWithoutTime = (Calendar.current as NSCalendar).components(components, from: self)
        return Calendar.current.date(from: componentsWithoutTime)!
    }

    var month: Int {
        return (Calendar.current as NSCalendar).components(.month, from: self).month!
    }

    var dayOfMonth: Int {
        return (Calendar.current as NSCalendar).components(.day, from: self).day!
    }

    var year: Int {
        return (Calendar.current as NSCalendar).components(.year, from: self).year!
    }

    var dayOfWeek: String {
        let dateFormatter = DateFormatter("EEEE")
        return dateFormatter.string(from: self)
    }

    var yearString: String {
        let dateFormatter = DateFormatter("yyyy")
        return dateFormatter.string(from: self)
    }

    func format(_ dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }

    func secondsSince(_ date: Date) -> TimeInterval {
        let seconds = Date().timeIntervalSince(date)
        return round(seconds * 100) / 100
    }
}
