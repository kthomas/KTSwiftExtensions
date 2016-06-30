//
//  BuildConfig.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/30/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import Foundation

#if DEBUG
let CurrentBuildConfig = BuildConfig.Debug
#elseif APP_STORE
let CurrentBuildConfig = BuildConfig.AppStore
#elseif true
let CurrentBuildConfig = BuildConfig.Debug
#endif

enum BuildConfig {
    case Debug, AppStore
}
