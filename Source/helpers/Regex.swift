//
//  Regex.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

class Regex {

    class func match(pattern: String, input: String) -> [NSTextCheckingResult] {
        return Regex(pattern).match(input)
    }

    let internalExpression: NSRegularExpression!
    let pattern: String

    init(_ pattern: String) {
        self.pattern = pattern

        do {
            internalExpression = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch let error as NSError {
            internalExpression = nil
            logWarn(error.localizedDescription)
        }
    }

    func match(input: String) -> [NSTextCheckingResult] {
        var matches = [NSTextCheckingResult]()
        if let internalExpression = internalExpression {
            matches = internalExpression.matchesInString(input, options: .Anchored, range: NSMakeRange(0, input.startIndex.distanceTo(input.endIndex)))
        }
        return matches
    }

    func test(input: String) -> Bool {
        return match(input).count > 0
    }
}
