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
        return DateFormatter("yyyy-MM-dd'T'HH:mm:ssZZ").date(from: string)
    }

    static func monthNameForNumber(_ month: Int) -> String {
        return DateFormatter().monthSymbols[month - 1]
    }

    var debugDescription: String {
        return DateFormatter("yyyy-MM-dd HH:mm:ss a").string(from: self)
    }

    var timeString: String? {
        return DateFormatter("hh:mm a").string(from: self)
    }

    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }

    var minutes: Int {
        return Calendar.current.component(.minute, from: self)
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
        return DateFormatter("MMMM").string(from: self)
    }

    var atMidnight: Date {
        let components = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day)
        let componentsWithoutTime = (Calendar.current as NSCalendar).components(components, from: self)
        return Calendar.current.date(from: componentsWithoutTime)!
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var dayOfMonth: Int {
        return (Calendar.current as NSCalendar).components(.day, from: self).day!
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var dayOfWeek: String {
        return DateFormatter("EEEE").string(from: self)
    }

    var yearString: String {
        return DateFormatter("yyyy").string(from: self)
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
