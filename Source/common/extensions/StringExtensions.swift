//
//  StringExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import Foundation

infix operator =~ { associativity right precedence 90 }
public func =~ (input: String, pattern: String) -> Bool {
    return KTRegex(pattern).test(input)
}

public extension String {

    var length: Int {
        return lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }

    func replaceString(target: String, withString replacementString: String) -> String {
        return stringByReplacingOccurrencesOfString(target, withString: replacementString)
    }

    var base64EncodedString: String {
        return NSData(bytes: (self as NSString).UTF8String, length: length).base64EncodedStringWithOptions([])
    }

    func urlEncodedString() -> String {
        return replaceString(" ", withString: "+").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }

    private func toJSONAnyObject() -> AnyObject! {
        do {
            let data = dataUsingEncoding(NSUTF8StringEncoding)
            let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
            return jsonObject
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

    func toJSONObject() -> [String : AnyObject]! {
        if let obj = toJSONAnyObject() as? [String : AnyObject] {
            return obj as [String : AnyObject]
        }
        return nil
    }

    func snakeCaseToCamelCaseString() -> String {
        let items: [String] = componentsSeparatedByString("_")
        var camelCase = ""
        var isFirst = true
        for item: String in items {
            if isFirst {
                isFirst = false
                camelCase += item
            } else {
                camelCase += item.capitalizedString
            }
        }
        return camelCase
    }

    func snakeCaseString() -> String {
        let pattern = try! NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
        return pattern.stringByReplacingMatchesInString(self, options: [], range: NSMakeRange(0, characters.count), withTemplate: "$1_$2").lowercaseString
    }

    var containsNonASCIICharacters: Bool {
        return !canBeConvertedToEncoding(NSASCIIStringEncoding)
    }

    // MARK: Validation Methods

    func contains(searchString: String) -> Bool {
        return rangeOfString(searchString) != nil
    }

    func containsRegex(searchString: String) -> Bool {
        return rangeOfString(searchString, options: .RegularExpressionSearch) != nil
    }

    func containsOneOrMoreNumbers() -> Bool {
        return rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil
    }

    func containsOneOrMoreUppercaseLetters() -> Bool {
        return rangeOfCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()) != nil
    }

    func containsOneOrMoreLowercaseLetters() -> Bool {
        return rangeOfCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet()) != nil
    }

    func isDigit() -> Bool {
        let int = Int(self)
        return (length == 1) && (int >= 0) && (int <= 9)
    }

    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluateWithObject(self)
    }

    func stringByStrippingHTML() -> String {
        var range = NSMakeRange(0, 0)
        var str = NSString(string: self)
        while range.location != NSNotFound {
            range = str.rangeOfString("<[^>]+>", options: NSStringCompareOptions.RegularExpressionSearch)
            if range.location != NSNotFound {
                str = str.stringByReplacingCharactersInRange(range, withString: "")
            }
        }
        return str as String
    }
}