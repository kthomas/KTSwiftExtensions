//
//  StringExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

private func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

infix operator =~ : AssignmentPrecedence
public func =~ (input: String, pattern: String) -> Bool {
    return KTRegex(pattern).test(input)
}

public extension String {

    var length: Int {
        return lengthOfBytes(using: String.Encoding.utf8)
    }

    func replaceString(_ target: String, withString replacementString: String) -> String {
        return replacingOccurrences(of: target, with: replacementString)
    }

    var base64EncodedString: String {
        return Data(bytes: [UInt8] (utf8)).base64EncodedString(options: [])
    }

    func urlEncodedString() -> String {
        return replaceString(" ", withString: "+").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }

    fileprivate func toJSONAnyObject() -> AnyObject! {
        do {
            let data = self.data(using: String.Encoding.utf8)
            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            return jsonObject as AnyObject
        } catch let error as NSError {
            logWarn(error.localizedDescription)
            return nil
        }
    }

    func toJSONArray() -> [AnyObject]! {
        if let arr = toJSONAnyObject() as? [AnyObject] {
            return arr as [AnyObject]
        }
        return nil
    }

    func toJSONObject() -> [String: AnyObject]! {
        if let obj = toJSONAnyObject() as? [String: AnyObject] {
            return obj as [String: AnyObject]
        }
        return nil
    }

    func snakeCaseToCamelCaseString() -> String {
        let items: [String] = components(separatedBy: "_")
        var camelCase = ""
        var isFirst = true
        for item: String in items {
            if isFirst {
                isFirst = false
                camelCase += item
            } else {
                camelCase += item.capitalized
            }
        }
        return camelCase
    }

    func snakeCaseString() -> String {
        guard let pattern = try? NSRegularExpression(pattern: "([a-z])([A-Z])", options: []) else { fatalError() }
        return pattern.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: characters.count), withTemplate: "$1_$2").lowercased()
    }

    var containsNonASCIICharacters: Bool {
        return !canBeConverted(to: String.Encoding.ascii)
    }

    // MARK: Validation Methods

    func containsRegex(_ searchString: String) -> Bool {
        return range(of: searchString, options: .regularExpression) != nil
    }

    func containsOneOrMoreNumbers() -> Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }

    func containsOneOrMoreUppercaseLetters() -> Bool {
        return rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }

    func containsOneOrMoreLowercaseLetters() -> Bool {
        return rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
    }

    func isDigit() -> Bool {
        let int = Int(self)
        return (length == 1) && (int >= 0) && (int <= 9)
    }

    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }

    func stringByStrippingHTML() -> String {
        var range = NSRange(location: 0, length: 0)
        var str = NSString(string: self)
        while range.location != NSNotFound {
            range = str.range(of: "<[^>]+>", options: NSString.CompareOptions.regularExpression)
            if range.location != NSNotFound {
                str = str.replacingCharacters(in: range, with: "") as NSString
            }
        }
        return str as String
    }
}
