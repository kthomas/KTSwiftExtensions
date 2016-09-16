//
//  KTRegex.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

open class KTRegex {

    open class func match(_ pattern: String, input: String) -> [NSTextCheckingResult] {
        return KTRegex(pattern).match(input)
    }

    let internalExpression: NSRegularExpression!
    let pattern: String

    public init(_ pattern: String) {
        self.pattern = pattern

        do {
            internalExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch let error as NSError {
            internalExpression = nil
            logWarn(error.localizedDescription)
        }
    }

    open func match(_ input: String) -> [NSTextCheckingResult] {
        var matches = [NSTextCheckingResult]()
        if let internalExpression = internalExpression {
            matches = internalExpression.matches(in: input, options: .anchored, range: NSMakeRange(0, input.characters.distance(from: input.startIndex, to: input.endIndex)))
        }
        return matches
    }

    open func test(_ input: String) -> Bool {
        return match(input).count > 0
    }
}
