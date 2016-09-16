//
//  KTVersionHelper.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 8/8/16.
//  Copyright © 2016 PROJECT_OWNER. All rights reserved.
//

import Foundation

open class KTVersionHelper {

    open class func buildNumber() -> String {
        return infoDictionaryValueFor("CFBundleVersion")
    }

    open class func shortVersion() -> String {
        return infoDictionaryValueFor("CFBundleShortVersionString")
    }

    open class func buildTime() -> String {
        return infoDictionaryValueFor("xBuildShortTime")
    }

    open class func gitSha() -> String {
        return infoDictionaryValueFor("xGitShortSHA")
    }

    open class func fullVersion() -> String {
        return "\(shortVersion()).\(buildNumber()) \(buildTime()) (\(gitSha()))"
    }
}
