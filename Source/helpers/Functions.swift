//
//  Functions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

typealias VoidBlock = () -> Void

let logTimestampDateFormatter = NSDateFormatter(dateFormat: "HH:mm:ss.SSS")

func classNameForObject(object: AnyObject) -> String {
    let objectName = NSStringFromClass(object.dynamicType)

    if let injectBundle = ENV("XCInjectBundle") {
        let testBundleName = NSString(string: NSString(string: injectBundle).lastPathComponent).stringByDeletingPathExtension
        return objectName.replaceString("\(testBundleName).", withString: "")
    } else {
        return objectName.componentsSeparatedByString(".").last!
    }
}

func decodeJSON(data: NSData) -> [String: AnyObject] {
    do {
        return try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String : AnyObject]
    } catch {
        log("\(error)")
        fatalError()
    }
}

func dispatch_after_delay(seconds: Double, block: dispatch_block_t) {
    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue(), block)
}

func dispatch_async_main_queue(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func dispatch_async_global_queue(priority: Int, block: dispatch_block_t) {
    dispatch_async(dispatch_get_global_queue(priority, 0), block)
}

func encodeJSON(input: AnyObject, options: NSJSONWritingOptions = []) -> NSData {
    let data: NSData?
    do {
        data = try NSJSONSerialization.dataWithJSONObject(input, options: options)
    } catch let error as NSError {
        logError(error)
        data = nil
    }
    return data!
}

func ENV(envVarName: String) -> String? {
    if var envVarValue = envVarRawValue(envVarName) {
        if envVarValue.hasPrefix("~") {
            let userHomeDir = envVarRawValue("SIMULATOR_HOST_HOME")!
            envVarValue = envVarValue.replaceString("~", withString: userHomeDir)
        }
        return envVarValue
    } else {
        return nil
    }
}

private func envVarRawValue(envVarName: String) -> String? {
    return NSProcessInfo.processInfo().environment[envVarName]
}

func isRunningUnitTests() -> Bool {
    if let injectBundle = ENV("XCInjectBundle") {
        return NSString(string: injectBundle).lastPathComponent.hasSuffix("Tests.xctest")
    }
    return false
}

func isIPad() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .Pad
}

func isIPhone() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .Phone
}

func isIPhone6Plus() -> Bool {
    if !isIPhone() {
        return false
    }
    return UIScreen.mainScreen().scale > 2.9
}

func isSimulator() -> Bool {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        return true
    #else
        return false
    #endif
}

func log(message: String, _ fileName: String = #file, _ functionName: String = #function, _ lineNumber: Int = #line) {
    if CurrentBuildConfig == .Debug {
        let timestamp = logTimestampDateFormatter.stringFromDate(NSDate())
        var fileAndMethod = "[\(timestamp)] [\(NSString(string: NSString(string: fileName).lastPathComponent).stringByDeletingPathExtension):\(lineNumber)] "
        fileAndMethod = fileAndMethod.replaceString("ViewController", withString: "VC")
        fileAndMethod = fileAndMethod.stringByPaddingToLength(38, withString: "-", startingAtIndex: 0)
        let logStatement = "\(fileAndMethod)--> \(message)"
        print(logStatement)
    }
}

func logError(error: NSError, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log("❌ NSError: \(error.localizedDescription)", fileName, functionName, lineNumber)
    fatalError("Encountered: NSError: \(error)")
}

func logError(errorMessage: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log("‼️ ERROR: \(errorMessage)", fileName, functionName, lineNumber)
}

func logWarn(errorMessage: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log("⚠️ WARNING: \(errorMessage)", fileName, functionName, lineNumber)
}

func logInfo(infoMessage: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log("🔵 INFO: \(infoMessage)", fileName, functionName, lineNumber)
}

func why(message: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    log("❓ WHY: \(message)", fileName, functionName, lineNumber)
}

func stringFromFile(fileName: String, bundlePath: String? = nil, bundle: NSBundle = NSBundle.mainBundle()) -> String {
    let resourceName = NSString(string: fileName).stringByDeletingPathExtension
    let type = NSString(string: fileName).pathExtension
    let filePath = bundle.pathForResource(resourceName, ofType: type, inDirectory:bundlePath)
    assert(filePath != nil, "File not found: \(resourceName).\(type)")

    let fileAsString: NSString?
    do {
        fileAsString = try NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
    } catch let error as NSError {
        logError(error.localizedDescription)
        fileAsString = nil
    }

    assert(fileAsString != nil)

    return fileAsString as! String
}

func prettyPrintedJson(uglyJsonStr: String?) -> String {
    if let uglyJsonString = uglyJsonStr {
        let uglyJson: AnyObject = try! NSJSONSerialization.JSONObjectWithData(uglyJsonString.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
        let prettyPrintedJson = encodeJSON(uglyJson, options: .PrettyPrinted)
        return NSString(data: prettyPrintedJson, encoding: NSUTF8StringEncoding) as! String
    }

    return ""
}

func swizzleMethodSelector(origSelector: String, withSelector: String, forClass: AnyClass) {
    let originalMethod = class_getInstanceMethod(forClass, Selector(origSelector))
    let swizzledMethod = class_getInstanceMethod(forClass, Selector(withSelector))
    method_exchangeImplementations(originalMethod, swizzledMethod)
}

func totalDeviceMemoryInGigabytes() -> CGFloat {
    return CGFloat(NSProcessInfo.processInfo().physicalMemory) / 1073741824.0
}

func windowBounds() -> CGRect {
    return UIApplication.sharedApplication().keyWindow!.bounds
}
