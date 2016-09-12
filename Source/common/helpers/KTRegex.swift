//
//  KTRegex.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

public class KTRegex {

    public class func match(pattern: String, input: String) -> [NSTextCheckingResult] {
        return KTRegex(pattern).match(input)
    }

    let internalExpression: NSRegularExpression!
    let pattern: String

    public init(_ pattern: String) {
        self.pattern = pattern

        do {
            internalExpression = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch let error as NSError {
            internalExpression = nil
            logWarn(error.localizedDescription)
        }
    }

    public func match(input: String) -> [NSTextCheckingResult] {
        var matches = [NSTextCheckingResult]()
        if let internalExpression = internalExpression {
            matches = internalExpression.matchesInString(input, options: .Anchored, range: NSMakeRange(0, input.startIndex.distanceTo(input.endIndex)))
        }
        return matches
    }

    public func test(input: String) -> Bool {
        return match(input).count > 0
    }
}